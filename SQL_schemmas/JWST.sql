CREATE TABLE `JWST` (
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
  `s_region` polygon,
  `obs_title` text,
  `target_name` varchar(255),
  `instrument_name` varchar(255),
  `project` varchar(255),
  `s_ra` float,
  `s_dec` float,
  `proposal_id` varchar(255)
);

CREATE TABLE `Targets` (
  `target_name` varchar(255) PRIMARY KEY,
  `target_classification` varchar(255)
);

CREATE TABLE `Instruments` (
  `instrument_name` varchar(255) PRIMARY KEY,
  `filters` varchar(255),
  `wavelength_region` varchar(255)
);

CREATE TABLE `Projects` (
  `project` varchar(255) PRIMARY KEY,
  `proposal_id` varchar(255),
  `proposal_type` varchar(255),
  `proposal_pi` varchar(255),
  `sequence_number` integer
);

CREATE TABLE `Provenance` (
  `obs_id` varchar(255),
  `provenance_name` varchar(255)
);

CREATE TABLE `SpatialData` (
  `obs_id` varchar(255) PRIMARY KEY,
  `s_ra` float,
  `s_dec` float,
  `s_region` polygon
);

ALTER TABLE `JWST` ADD FOREIGN KEY (`target_name`) REFERENCES `Targets` (`target_name`);

ALTER TABLE `JWST` ADD FOREIGN KEY (`instrument_name`) REFERENCES `Instruments` (`instrument_name`);

ALTER TABLE `JWST` ADD FOREIGN KEY (`project`) REFERENCES `Projects` (`project`);

ALTER TABLE `JWST` ADD FOREIGN KEY (`proposal_id`) REFERENCES `Projects` (`proposal_id`);

ALTER TABLE `Provenance` ADD FOREIGN KEY (`obs_id`) REFERENCES `JWST` (`obs_id`);

ALTER TABLE `SpatialData` ADD FOREIGN KEY (`obs_id`) REFERENCES `JWST` (`obs_id`);
