CREATE TABLE `ALMA` (
  `obs_id` varchar(255) PRIMARY KEY,
  `obs_collection` varchar(255),
  `intentType` varchar(255),
  `dataproduct_type` varchar(255),
  `calib_level` integer,
  `t_min` float,
  `t_max` float,
  `t_exptime` float,
  `em_min` float,
  `em_max` float,
  `t_obs_release` float,
  `dataRights` varchar(255),
  `mtFlag` boolean,
  `srcDen` float,
  `obsid` bigint,
  `objID` bigint,
  `jpegURL` varchar(255),
  `dataURL` varchar(255),
  `s_region` varchar(255),
  `obs_title` varchar(255),
  `target_name` varchar(255),
  `instrument_name` varchar(255),
  `project` varchar(255),
  `s_ra` float,
  `s_dec` float,
  `facility_name` varchar(255),
  `s_fov` float,
  `s_xel1` float,
  `s_xel2` float,
  `em_xel` float,
  `t_xel` float,
  `pol_xel` float,
  `s_resolution` float,
  `t_resolution` float,
  `em_res_power` float,
  `pol_states` varchar(255),
  `cont_sensitivity_bandwidth` float,
  `pwv` float,
  `group_ous_uid` varchar(255),
  `member_ous_uid` varchar(255),
  `asdm_uid` varchar(255),
  `type` varchar(255),
  `scan_intent` varchar(255),
  `science_observation` boolean,
  `spatial_scale_max` float,
  `qa2_passed` boolean,
  `bib_reference` varchar(255),
  `science_keyword` varchar(255),
  `scientific_category` varchar(255),
  `pi_userid` varchar(255),
  `pi_name` varchar(255),
  `spectral_resolution` float,
  `o_ucd` varchar(255),
  `access_url` varchar(255),
  `access_format` varchar(255),
  `access_estsize` float,
  `proposal_id` varchar(255),
  `gal_longitude` float,
  `gal_latitude` float,
  `band_list` varchar(255),
  `em_resolution` float,
  `bandwidth` float,
  `antenna_arrays` varchar(255),
  `is_mosaic` boolean,
  `obs_release_date` float,
  `spatial_resolution` float,
  `frequency_support` varchar(255),
  `frequency` float,
  `velocity_resolution` float,
  `obs_creator_name` varchar(255),
  `pub_title` varchar(255),
  `first_author` varchar(255),
  `authors` text,
  `pub_abstract` text,
  `publication_year` integer,
  `proposal_abstract` text,
  `schedblock_name` varchar(255),
  `proposal_authors` text,
  `sensitivity_10kms` float,
  `lastModified` timestamp
);

CREATE TABLE `Target` (
  `target_name` varchar(255) PRIMARY KEY,
  `target_classification` varchar(255)
);

CREATE TABLE `Instrument` (
  `instrument_name` varchar(255) PRIMARY KEY,
  `filters` varchar(255),
  `wavelength_region` varchar(255)
);

CREATE TABLE `Project` (
  `project` varchar(255) PRIMARY KEY,
  `proposal_id` varchar(255),
  `proposal_type` varchar(255),
  `proposal_pi` varchar(255),
  `sequence_number` integer
);

CREATE TABLE `Coordinates` (
  `obs_id` varchar(255) PRIMARY KEY,
  `s_ra` float,
  `s_dec` float,
  `s_fov` float,
  `s_region` varchar(255)
);

CREATE TABLE `ObservationDetails` (
  `obs_id` varchar(255) PRIMARY KEY,
  `obs_title` varchar(255),
  `type` varchar(255),
  `scan_intent` varchar(255),
  `science_observation` boolean,
  `qa2_passed` boolean,
  `obs_creator_name` varchar(255),
  `obs_release_date` float,
  `schedblock_name` varchar(255),
  `lastModified` timestamp
);

CREATE TABLE `DataAccess` (
  `obs_id` varchar(255) PRIMARY KEY,
  `jpegURL` varchar(255),
  `dataURL` varchar(255),
  `access_url` varchar(255),
  `access_format` varchar(255),
  `access_estsize` float
);

CREATE TABLE `ScienceKeywords` (
  `obs_id` varchar(255) PRIMARY KEY,
  `science_keyword` varchar(255),
  `scientific_category` varchar(255),
  `bib_reference` varchar(255),
  `pub_title` varchar(255),
  `first_author` varchar(255),
  `authors` text,
  `pub_abstract` text,
  `publication_year` integer
);

ALTER TABLE `ALMA` ADD FOREIGN KEY (`target_name`) REFERENCES `Target` (`target_name`);

ALTER TABLE `ALMA` ADD FOREIGN KEY (`instrument_name`) REFERENCES `Instrument` (`instrument_name`);

ALTER TABLE `ALMA` ADD FOREIGN KEY (`project`) REFERENCES `Project` (`project`);

ALTER TABLE `Coordinates` ADD FOREIGN KEY (`obs_id`) REFERENCES `ALMA` (`obs_id`);

ALTER TABLE `ObservationDetails` ADD FOREIGN KEY (`obs_id`) REFERENCES `ALMA` (`obs_id`);

ALTER TABLE `DataAccess` ADD FOREIGN KEY (`obs_id`) REFERENCES `ALMA` (`obs_id`);

ALTER TABLE `ScienceKeywords` ADD FOREIGN KEY (`obs_id`) REFERENCES `ALMA` (`obs_id`);
