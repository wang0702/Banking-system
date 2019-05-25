/*
 Navicat Premium Data Transfer

 Source Server         : test
 Source Server Type    : MySQL
 Source Server Version : 50726
 Source Host           : localhost
 Source Database       : zyl

 Target Server Type    : MySQL
 Target Server Version : 50726
 File Encoding         : utf-8

 Date: 05/25/2019 12:28:23 PM
*/

SET NAMES utf8;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
--  Table structure for `account`
-- ----------------------------
DROP TABLE IF EXISTS `account`;
CREATE TABLE `account` (
  `account_number` varchar(10) NOT NULL,
  `branch_name` varchar(15) NOT NULL,
  `balance` decimal(12,2) DEFAULT NULL,
  PRIMARY KEY (`account_number`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

-- ----------------------------
--  Records of `account`
-- ----------------------------
BEGIN;
INSERT INTO `account` VALUES ('A-101', 'Downtown', '300.00'), ('A-102', 'Perryridge', '400.00'), ('A-201', 'Brighton', '1600.00'), ('A-213', 'Perryridge', '250.00'), ('A-214', 'Perryridge', null), ('A-215', 'Mianus', '700.00'), ('A-217', 'Brighton', '750.00'), ('A-222', 'Redwood', '700.00'), ('A-305', 'Round', '350.00');
COMMIT;

-- ----------------------------
--  Table structure for `borrower`
-- ----------------------------
DROP TABLE IF EXISTS `borrower`;
CREATE TABLE `borrower` (
  `customer_name` varchar(50) NOT NULL,
  `loan_number` varchar(50) NOT NULL,
  PRIMARY KEY (`customer_name`,`loan_number`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

-- ----------------------------
--  Table structure for `branch`
-- ----------------------------
DROP TABLE IF EXISTS `branch`;
CREATE TABLE `branch` (
  `branch_name` varchar(50) NOT NULL,
  `branch_city` varchar(50) DEFAULT NULL,
  `assets` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`branch_name`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

-- ----------------------------
--  Table structure for `customer`
-- ----------------------------
DROP TABLE IF EXISTS `customer`;
CREATE TABLE `customer` (
  `customer_name` varchar(50) NOT NULL,
  `customer_steet` varchar(50) DEFAULT NULL,
  `customer_city` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`customer_name`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

-- ----------------------------
--  Table structure for `depositor`
-- ----------------------------
DROP TABLE IF EXISTS `depositor`;
CREATE TABLE `depositor` (
  `customer_name` varchar(50) NOT NULL,
  `account_number` varchar(50) NOT NULL,
  PRIMARY KEY (`customer_name`,`account_number`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

-- ----------------------------
--  Table structure for `loan`
-- ----------------------------
DROP TABLE IF EXISTS `loan`;
CREATE TABLE `loan` (
  `loan_number` int(50) NOT NULL AUTO_INCREMENT,
  `branch_name` varchar(50) DEFAULT NULL,
  `amount` decimal(12,2) DEFAULT NULL,
  `pay_over_date` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`loan_number`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

-- ----------------------------
--  Records of `loan`
-- ----------------------------
BEGIN;
INSERT INTO `loan` VALUES ('1', 'TEST', '500.00', null), ('2', 'Branch1', '1000.00', null), ('3', 'Branch1', '900.00', null), ('4', 'Branch1', '800.00', null), ('5', 'Branch1', '400.00', null), ('6', 'Branch1', '6000.00', null);
COMMIT;

-- ----------------------------
--  Table structure for `payment`
-- ----------------------------
DROP TABLE IF EXISTS `payment`;
CREATE TABLE `payment` (
  `payment_number` int(50) NOT NULL AUTO_INCREMENT,
  `loan_number` int(50) NOT NULL,
  `payment_datetime` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `payment_amount` decimal(12,2) DEFAULT NULL,
  PRIMARY KEY (`payment_number`,`loan_number`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=132 DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

-- ----------------------------
--  Records of `payment`
-- ----------------------------
BEGIN;
INSERT INTO `payment` VALUES ('127', '1', '2019-05-13 21:07:49', '99.00'), ('128', '1', '2019-05-13 21:07:51', '99.00'), ('129', '1', '2019-05-13 21:07:52', '99.00'), ('130', '1', '2019-05-13 21:07:52', '99.00'), ('131', '1', '2019-05-13 21:07:53', '99.00');
COMMIT;

-- ----------------------------
--  Procedure structure for `payback`
-- ----------------------------
DROP PROCEDURE IF EXISTS `payback`;
delimiter ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `payback`(IN loan_id INT,IN amount NUMERIC,out errorVar int,OUT leftMoney NUMERIC)
main: BEGIN
		DECLARE mont int DEFAULT 0;
		DECLARE res int DEFAULT 0;
		DECLARE error INTEGER DEFAULT 0;
		DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET error = -1;
		IF ( (SELECT loan.amount FROM loan WHERE loan_number = loan_id) IS NULL ) THEN
			SET errorVar = -3;
			LEAVE main;
		END IF;
		IF ( (SELECT loan.pay_over_date FROM loan WHERE loan_number = loan_id) IS NOT NULL ) THEN
			SET errorVar = -4;
			LEAVE main;
		END IF;
		SELECT loan.amount FROM loan WHERE loan_number = loan_id into mont;
		SELECT SUM(payment_amount) FROM payment WHERE loan_number = loan_id into res;
		IF res IS NULL THEN
			SET res = 0;
		END IF;
		IF (amount > mont) THEN
			SET errorVar = -2;
			SET leftMoney = mont - res;
			LEAVE main;
		END IF;	
		IF (res + amount > mont) THEN
			SET errorVar = -2;
			SET leftMoney = mont - res;
			LEAVE main;
		END IF;		
		START TRANSACTION;
			INSERT INTO payment (loan_number,payment_amount) VALUES (loan_id,amount);
			set errorVar = error;
			IF errorVar != 0 THEN
				ROLLBACK;
				SET errorVar = error;
				LEAVE main;
			END IF;
			IF (res + amount = mont) THEN
				UPDATE loan SET pay_over_date = CURRENT_TIMESTAMP WHERE loan_number = loan_id;
				set errorVar = error;
				IF errorVar != 0 THEN
					ROLLBACK;
					SET errorVar = error;
					LEAVE main;
				END IF;
			END IF;
			SET leftMoney = mont - amount - res;
		COMMIT;
END main
 ;;
delimiter ;

-- ----------------------------
--  Procedure structure for `PTransfer`
-- ----------------------------
DROP PROCEDURE IF EXISTS `PTransfer`;
delimiter ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `PTransfer`(IN	account_no_x varchar(30),
	IN account_no_y varchar(30),
	IN amount_k NUMERIC(8,2),OUT ErrorVar INT)
test:	BEGIN
		DECLARE error INTEGER DEFAULT 0;
		DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET error = 1;
		IF (SELECT balance 
			 FROM account 
			 WHERE account_number = account_no_x) IS NULL
			OR
			(SELECT balance 
			 FROM account 
			 WHERE account_number = account_no_y) IS NULL
		THEN
			SET ErrorVar = -1;
			LEAVE test;
		END IF;
		START TRANSACTION;
			UPDATE account 
			SET account.balance = account.balance + amount_k 
			WHERE account.account_number = account_no_y;
			set ErrorVar = error;	
			IF ErrorVar != 0	THEN
				BEGIN
					ROLLBACK;	
					LEAVE test;
				END;
			END IF;
			UPDATE account
			SET balance = balance - amount_k
			WHERE account_number = account_no_x;
			set ErrorVar = error;	
			IF (SELECT balance FROM account WHERE account_number = account_no_x) < 0 THEN
				ROLLBACK;
				SET ErrorVar = -1;
				LEAVE test;
			END IF;
			IF ErrorVar != 0	THEN
				BEGIN
					ROLLBACK;	
					SET ErrorVar = error;
				END;
			END IF;
			COMMIT;
		SET ErrorVar = 0;
	END test
 ;;
delimiter ;

SET FOREIGN_KEY_CHECKS = 1;
