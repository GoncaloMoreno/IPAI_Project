CREATE TABLE `HAWKI` (
  `dataset_id` varchar(255) PRIMARY KEY,
  `object_name` varchar(255),
  `ra` float,
  `dec` float,
  `program_id` varchar(255),
  `instrument` varchar(255),
  `category` varchar(255),
  `type` varchar(255),
  `mode` varchar(255),
  `release_date` timestamp,
  `tpl_id` varchar(255),
  `tpl_start` timestamp,
  `exptime` float,
  `filter_lambda_min` float,
  `filter_lambda_max` float,
  `filter` varchar(255),
  `mjd_obs` float,
  `airmass` float,
  `dimm_seeing_start` float
);

CREATE TABLE `Objects` (
  `object_name` varchar(255) PRIMARY KEY,
  `category` varchar(255),
  `type` varchar(255)
);

CREATE TABLE `Programs` (
  `program_id` varchar(255) PRIMARY KEY,
  `program_name` varchar(255)
);

CREATE TABLE `Instruments` (
  `instrument_name` varchar(255) PRIMARY KEY,
  `mode` varchar(255),
  `filter` varchar(255)
);

CREATE TABLE `Filters` (
  `filter_name` varchar(255) PRIMARY KEY,
  `lambda_min` float,
  `lambda_max` float,
  `instrument_name` varchar(255)
);

CREATE TABLE `ObservationConditions` (
  `dataset_id` varchar(255) PRIMARY KEY,
  `mjd_obs` float,
  `airmass` float,
  `dimm_seeing_start` float,
  `tpl_start` timestamp
);

CREATE TABLE `ExposureDetails` (
  `dataset_id` varchar(255) PRIMARY KEY,
  `exptime` float,
  `tpl_id` varchar(255),
  `release_date` timestamp
);

ALTER TABLE `HAWKI` ADD FOREIGN KEY (`object_name`) REFERENCES `Objects` (`object_name`);

ALTER TABLE `HAWKI` ADD FOREIGN KEY (`program_id`) REFERENCES `Programs` (`program_id`);

ALTER TABLE `HAWKI` ADD FOREIGN KEY (`instrument`) REFERENCES `Instruments` (`instrument_name`);

ALTER TABLE `Filters` ADD FOREIGN KEY (`instrument_name`) REFERENCES `Instruments` (`instrument_name`);

ALTER TABLE `ObservationConditions` ADD FOREIGN KEY (`dataset_id`) REFERENCES `HAWKI` (`dataset_id`);

ALTER TABLE `ExposureDetails` ADD FOREIGN KEY (`dataset_id`) REFERENCES `HAWKI` (`dataset_id`);
