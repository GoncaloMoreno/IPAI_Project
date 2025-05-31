#!/usr/bin/env python
# coding: utf-8

import pandas as pd
import numpy as np
from ydata_profiling import ProfileReport
from astropy.coordinates import SkyCoord
import astropy.units as units
import networkx as nx 
from scipy.spatial.distance import pdist, squareform
from sklearn.metrics.pairwise import haversine_distances
from joblib import Parallel, delayed
from collections import defaultdict
from rapidfuzz import fuzz
from sklearn.preprocessing import MultiLabelBinarizer
import logging
import os
from datetime import datetime

# Set up logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('pipeline_run.log'),
        logging.StreamHandler()
    ]
)

class DataProcessingPipeline:
    def __init__(self, data_dir='./Datasets'):
        self.data_dir = data_dir
        self.datasets = {}
        self.merged_df = None
        self.output_dir = 'pipeline_outputs'
        
    def load_datasets(self):
        """Load and preprocess all datasets"""
        try:
            # Load TESS data
            tess = pd.read_csv(os.path.join(self.data_dir, 'tessqueries.csv'))
            self._preprocess_tess(tess)
            self.datasets['TESS'] = tess
            
            # Load ALMA data
            alma = pd.read_csv(os.path.join(self.data_dir, 'almaqueries.csv'))
            self._preprocess_alma(alma)
            self.datasets['ALMA'] = alma
            
            # Load HAWKI data
            hawki = pd.read_csv(os.path.join(self.data_dir, 'vltqueries.csv'))
            self._preprocess_hawki(hawki)
            self.datasets['HAWKI'] = hawki
            
            logging.info("Successfully loaded all datasets")
            print(self.datasets)  # Should show the loaded datasets
            return True
        except Exception as e:
            logging.error(f"Error loading datasets: {str(e)}")
            return False

    def _preprocess_tess(self, df):
        """Preprocess TESS dataset"""
        # Drop columns with high missing values
        missing_proportions = df.isnull().mean()
        threshold = 0.5
        df.drop(columns=missing_proportions[missing_proportions > threshold].index, inplace=True)
        
        # Drop specified columns
        columns_to_drop = [
            "intentType", "obs_collection", "provenance_name", "instrument_name", "project",
            "filters", "wavelength_region", "target_classification", "obs_id", "proposal_pi",
            "calib_level", "t_exptime", "obs_title", "t_obs_release", "proposal_id",
            "proposal_type", "sequence_number", "s_region", "jpegURL", "dataRights", "mtFlag",
            "srcDen", "objID", "dataproduct_type", 'dataURL', 'obsid'
        ]
        df.drop(columns=[col for col in columns_to_drop if col in df.columns], inplace=True)

    def _preprocess_alma(self, df):
        """Preprocess ALMA dataset"""
        # Convert wavelength from mm to nm
        mm_to_nm = 1e6
        if 'em_min' in df.columns:
            df['em_min'] = df['em_min'] * mm_to_nm
        if 'em_max' in df.columns:
            df['em_max'] = df['em_max'] * mm_to_nm

    def _preprocess_hawki(self, df):
        """Preprocess HAWKI dataset"""
        df.rename(columns={
            'OBJECT': 'target_name',
            'RA': 's_ra',
            'DEC': 's_dec',
            'filter_lambda_min': 'em_min',
            'filter_lambda_max': 'em_max'
        }, inplace=True)
        
        df['target_name'] = df['target_name'].fillna('')
        
        columns_to_drop = [
            'Program_ID', 'Instrument', 'Category', 'Type', 'Mode', 'Dataset ID',
            'Release_Date', 'TPL ID', 'TPL START', 'Filter', 'Airmass',
            'DIMM Seeing at Start', 'Exptime'
        ]
        df.drop(columns=[col for col in columns_to_drop if col in df.columns], inplace=True)

    def generate_profile_reports(self):
        """Generate profile reports for each dataset and the merged dataset"""
        try:
            # Create reports directory if it doesn't exist
            reports_dir = os.path.join(self.output_dir, 'profile_reports')
            os.makedirs(reports_dir, exist_ok=True)
            
            # Generate reports for individual datasets
            for dataset_name, df in self.datasets.items():
                logging.info(f"Generating profile report for {dataset_name}")
                profile = ProfileReport(df, title=f"{dataset_name} Dataset Profile")
                profile.to_file(os.path.join(reports_dir, f"{dataset_name.lower()}_profile.html"))
            
            # Generate report for merged dataset
            if self.merged_df is not None:
                logging.info("Generating profile report for merged dataset")
                profile = ProfileReport(self.merged_df, title="Merged Dataset Profile")
                profile.to_file(os.path.join(reports_dir, "merged_profile.html"))
            
            logging.info("Successfully generated all profile reports")
            return True
        except Exception as e:
            logging.error(f"Error generating profile reports: {str(e)}")
            return False

    def merge_datasets(self):
        """Merge all datasets with appropriate dataset labels"""
        dfs = []
        for dataset_name, df in self.datasets.items():
            df['dataset'] = dataset_name
            dfs.append(df)
        
        self.merged_df = pd.concat(dfs, ignore_index=True)
        logging.info(f"Successfully merged {len(self.datasets)} datasets")
        return self.merged_df

def create_coordinate_blocks(df, block_size=1.0):
    """
    Create spatial blocks for the dataset based on RA and DEC coordinates.
    block_size is in degrees.
    """
    # Create blocks by rounding coordinates to nearest block_size
    df['coord_block'] = (
        (df['s_ra'] // block_size).astype(int).astype(str) + '_' +
        (df['s_dec'] // block_size).astype(int).astype(str)
    )
    return df

class DataFusionPipeline:
    def __init__(self, df):
        self.df = df.copy()
        self.instrument_ages = {
            'JWST': 1,    # ~3.5 years (newest)
            'TESS': 2,    # ~7 years  
            'ALMA': 3,    # ~12 years
            'HAWKI': 4    # ~18 years (oldest)
        }
        self.instrument_expertise = {
            'TESS': {'min_nm': 600, 'max_nm': 1000, 'priority': 3},
            'HAWKI': {'min_nm': 1100, 'max_nm': 2500, 'priority': 2},
            'JWST': {'min_nm': 600, 'max_nm': 28500, 'priority': 4},
            'ALMA': {'min_nm': 300000, 'max_nm': 10000000, 'priority': 4}
        }

    def matches_deduplication(self, name_thres=0.8, spatial_tresh=1, temp_thresh=7, parallel=False):
        """Perform deduplication on the dataset"""
        # Create coordinate blocks first
        self.df = create_coordinate_blocks(self.df)
        
        G = nx.Graph()
        G.add_nodes_from(self.df.index)
        coord_groups = defaultdict(list)

        # Group by coordinates
        for idx, row in self.df.iterrows():
            coord_groups[row['coord_block']].append(idx)

        # Process each group
        for coord_block, indices in coord_groups.items():
            group = self.df.loc[indices]
            if len(group) == 1:
                continue

            # Calculate spatial distances
            coords = group[['s_ra', 's_dec']].values
            coords_rad = np.radians(coords)
            spatial_dists = np.degrees(haversine_distances(coords_rad))

            # Calculate temporal differences
            times = group['MJD-OBS'].values
            time_diffs = squareform(pdist(times[:, None]))

            # Calculate name similarities
            names = group['target_name'].values
            tokenized_names = [name.split() for name in names]
            mlb = MultiLabelBinarizer()
            binary_matrix = mlb.fit_transform(tokenized_names)
            jaccard_dists = pdist(binary_matrix, metric='jaccard')
            name_sims = 1 - squareform(jaccard_dists)

            # Apply thresholds
            mask = (spatial_dists <= spatial_tresh) & (time_diffs <= temp_thresh) & (name_sims >= name_thres)
            rows, cols = np.where(mask)
            for r, c in zip(rows, cols):
                if r < c:
                    G.add_edge(group.index[r], group.index[c])

        # Extract clusters and representatives
        clusters = [list(c) for c in nx.connected_components(G)]
        representatives = []
        for cluster in clusters:
            cluster_df = self.df.loc[cluster]
            cluster_df = cluster_df.sort_values(['MJD-OBS'], ascending=True)
            representatives.append(cluster_df.iloc[0])

        dedup_df = pd.DataFrame(representatives).reset_index(drop=True)
        logging.info(f"Reduced from {len(self.df)} to {len(dedup_df)} unique objects")
        return dedup_df, clusters

    def apply_temporal_resolution(self, clusters):
        """Apply temporal resolution strategy"""
        resolution_log = {
            'total_clusters': len(clusters),
            'objects_before': len(self.df),
            'resolved_by_instrument': {},
            'resolved_by_date': 0,
            'tie_breakers': 0
        }

        df_copy = self.df.copy()
        df_copy['instrument_age'] = df_copy['dataset'].map(self.instrument_ages)
        
        elimination_details = []
        for cluster_idx, cluster in enumerate(clusters):
            if len(cluster) <= 1:
                continue

            cluster_df = df_copy.iloc[cluster].copy()
            min_age = cluster_df['instrument_age'].min()
            newest_mask = cluster_df['instrument_age'] == min_age
            newest_indices = cluster_df[newest_mask].index.tolist()

            if len(newest_indices) == 1:
                winner_idx = newest_indices[0]
                losers = [idx for idx in cluster if idx != winner_idx]
                
                for loser_idx in losers:
                    elimination_details.append({
                        'eliminated_idx': loser_idx,
                        'winner_idx': winner_idx,
                        'cluster_id': cluster_idx,
                        'elimination_reason': 'instrument_age',
                        'winner_instrument': df_copy.loc[winner_idx, 'dataset'],
                        'loser_instrument': df_copy.loc[loser_idx, 'dataset']
                    })

        return elimination_details

def main():
    """Main execution function"""
    try:
        # Initialize and run data processing pipeline
        data_pipeline = DataProcessingPipeline()
        data_pipeline.load_datasets()  # Load the datasets
        merged_df = data_pipeline.merge_datasets()  # Merge the datasets
        
        # Generate profile reports for individual datasets
        if not data_pipeline.generate_profile_reports():
            raise Exception("Failed to generate profile reports")
        
        # Initialize and run data fusion pipeline
        fusion_pipeline = DataFusionPipeline(merged_df)
        dedup_df, clusters = fusion_pipeline.matches_deduplication()
        
        # Apply temporal resolution
        elimination_details = fusion_pipeline.apply_temporal_resolution(clusters)
        
        # Save results
        dedup_df.to_csv('pipeline_outputs/deduplicated_data.csv', index=False)
        pd.DataFrame(elimination_details).to_csv('pipeline_outputs/elimination_details.csv', index=False)
        
        logging.info("Pipeline completed successfully")
        
    except Exception as e:
        logging.error(f"Pipeline failed: {str(e)}")
        raise

if __name__ == "__main__":
    # Create output directory if it doesn't exist
    os.makedirs('pipeline_outputs', exist_ok=True)
    main() 