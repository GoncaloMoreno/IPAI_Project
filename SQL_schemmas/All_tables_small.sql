CREATE TABLE `TESS` (
  `target_name` varchar(255),
  `s_ra` float,
  `s_dec` float,
  `em` float,
  `MJD_OBS` float,
  `dataset` varchar(255),
  `coord_block` float,
  `temp_block` float
);

CREATE TABLE `ALMA` (
  `target_name` varchar(255),
  `s_ra` float,
  `s_dec` float,
  `em` float,
  `MJD_OBS` float,
  `dataset` varchar(255),
  `coord_block` float,
  `temp_block` float
);

CREATE TABLE `JWST` (
  `target_name` varchar(255),
  `s_ra` float,
  `s_dec` float,
  `em` float,
  `MJD_OBS` float,
  `dataset` varchar(255),
  `coord_block` float,
  `temp_block` float
);

CREATE TABLE `HAWKI` (
  `target_name` varchar(255),
  `s_ra` float,
  `s_dec` float,
  `em` float,
  `MJD_OBS` float,
  `dataset` varchar(255),
  `coord_block` float,
  `temp_block` float
);
