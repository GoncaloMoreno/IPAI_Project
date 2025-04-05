CREATE TABLE `TESS` (
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
  `s_dec` float
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
  `s_dec` float
);

ALTER TABLE `TESS` ADD FOREIGN KEY (`target_name`) REFERENCES `Target` (`target_name`);

ALTER TABLE `TESS` ADD FOREIGN KEY (`instrument_name`) REFERENCES `Instrument` (`instrument_name`);

ALTER TABLE `TESS` ADD FOREIGN KEY (`project`) REFERENCES `Project` (`project`);

ALTER TABLE `TESS` ADD FOREIGN KEY (`obs_id`) REFERENCES `Coordinates` (`obs_id`);
