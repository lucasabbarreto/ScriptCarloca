-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
-- -----------------------------------------------------
-- Schema carloca
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema carloca
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `carloca` DEFAULT CHARACTER SET utf8mb3 ;
USE `carloca` ;

-- -----------------------------------------------------
-- Table `carloca`.`carros`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `carloca`.`carros` (
  `ID` INT NOT NULL AUTO_INCREMENT,
  `PLACA` VARCHAR(45) NOT NULL,
  `MODELO` VARCHAR(45) NULL DEFAULT NULL,
  `MONTADORA` VARCHAR(45) NULL DEFAULT NULL,
  `COR` VARCHAR(45) NULL DEFAULT NULL,
  `VERSAO` VARCHAR(45) NULL DEFAULT NULL,
  `KM_TOTAL` INT NULL DEFAULT NULL,
  `VALOR_DIARIA` INT NOT NULL,
  `ESTA_LOCADO` TINYINT NOT NULL,
  PRIMARY KEY (`ID`))
ENGINE = InnoDB
AUTO_INCREMENT = 4
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `carloca`.`locadoras`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `carloca`.`locadoras` (
  `ID` INT NOT NULL AUTO_INCREMENT,
  `LOGRADOURO` VARCHAR(45) NULL DEFAULT NULL,
  `NUMERO` VARCHAR(10) NULL DEFAULT NULL,
  `BAIRRO` VARCHAR(45) NULL DEFAULT NULL,
  `CIDADE` VARCHAR(45) NULL DEFAULT NULL,
  `UF` VARCHAR(2) NULL DEFAULT NULL,
  `CEP` VARCHAR(8) NULL DEFAULT NULL,
  PRIMARY KEY (`ID`))
ENGINE = InnoDB
AUTO_INCREMENT = 3
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `carloca`.`usuarios`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `carloca`.`usuarios` (
  `ID` INT NOT NULL AUTO_INCREMENT,
  `NOME` VARCHAR(45) NOT NULL,
  `CPF` VARCHAR(45) NOT NULL,
  `TEM_CARRO_LOCADO` TINYINT NOT NULL,
  PRIMARY KEY (`ID`),
  UNIQUE INDEX `CPF_UNIQUE` (`CPF` ASC))
ENGINE = InnoDB
AUTO_INCREMENT = 6
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `carloca`.`historico_carros`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `carloca`.`historico_carros` (
  `ID` INT NOT NULL AUTO_INCREMENT,
  `KM_RODADOS` INT NULL DEFAULT NULL,
  `DATA_RETIRADA` DATE NULL DEFAULT NULL,
  `LOCAL_RETIRADA` INT NULL DEFAULT NULL,
  `DATA_ENTREGA` DATE NULL DEFAULT NULL,
  `LOCAL_ENTREGA` INT NULL DEFAULT NULL,
  `VALOR_PAGO` INT NULL DEFAULT NULL,
  `CARROS_ID` INT NULL DEFAULT NULL,
  `USUARIOS_ID` INT NULL DEFAULT NULL,
  PRIMARY KEY (`ID`),
  INDEX `fk_HISTORICO_CARROS_LOCADORAS_idx` (`LOCAL_ENTREGA` ASC, `LOCAL_RETIRADA` ASC),
  INDEX `fk_historico_carros_carros1_idx` (`CARROS_ID` ASC),
  INDEX `fk_historico_carros_usuarios1_idx` (`USUARIOS_ID` ASC),
  INDEX `fk_historico_carros_locadoras1_idx` (`LOCAL_RETIRADA` ASC),
  CONSTRAINT `fk_historico_carros_carros1`
    FOREIGN KEY (`CARROS_ID`)
    REFERENCES `carloca`.`carros` (`ID`),
  CONSTRAINT `fk_historico_carros_locadoras1`
    FOREIGN KEY (`LOCAL_RETIRADA`)
    REFERENCES `carloca`.`locadoras` (`ID`),
  CONSTRAINT `fk_historico_carros_locadoras2`
    FOREIGN KEY (`LOCAL_ENTREGA`)
    REFERENCES `carloca`.`locadoras` (`ID`),
  CONSTRAINT `fk_historico_carros_usuarios1`
    FOREIGN KEY (`USUARIOS_ID`)
    REFERENCES `carloca`.`usuarios` (`ID`))
ENGINE = InnoDB
AUTO_INCREMENT = 21
DEFAULT CHARACTER SET = utf8mb3;

USE `carloca`;

DELIMITER $$
USE `carloca`$$
CREATE
DEFINER=`root`@`localhost`
TRIGGER `carloca`.`COR_INVALIDA`
BEFORE INSERT ON `carloca`.`carros`
FOR EACH ROW
BEGIN
IF (NEW.COR != 'PRATA' AND NEW.COR != 'PRETO' AND NEW.COR != 'BRANCO')
THEN 
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'COR INVALIDA';
END IF;
END$$

USE `carloca`$$
CREATE
DEFINER=`root`@`localhost`
TRIGGER `carloca`.`DISPONIBILIZAR_CARRO`
AFTER UPDATE ON `carloca`.`historico_carros`
FOR EACH ROW
BEGIN
  IF (OLD.DATA_ENTREGA IS NULL) 
  THEN
  UPDATE CARROS 
  SET ESTA_LOCADO = 0
  WHERE ID = OLD.CARROS_ID;
  UPDATE USUARIOS
  SET TEM_CARRO_LOCADO = 0
  WHERE ID = OLD.USUARIOS_ID;
  END IF;
END$$

USE `carloca`$$
CREATE
DEFINER=`root`@`localhost`
TRIGGER `carloca`.`LOCAR_VEICULO`
AFTER INSERT ON `carloca`.`historico_carros`
FOR EACH ROW
BEGIN
	UPDATE CARROS 
    SET ESTA_LOCADO = 1
    WHERE ID = NEW.CARROS_ID; 
    UPDATE USUARIOS
    SET TEM_CARRO_LOCADO = 1
    WHERE ID = NEW.USUARIOS_ID;
END$$

USE `carloca`$$
CREATE
DEFINER=`root`@`localhost`
TRIGGER `carloca`.`VERIFICAR_LOCACAO`
BEFORE INSERT ON `carloca`.`historico_carros`
FOR EACH ROW
BEGIN
	IF EXISTS(SELECT ID, TEM_CARRO_LOCADO 
    FROM USUARIOS WHERE ID = NEW.USUARIOS_ID AND TEM_CARRO_LOCADO = 1)
    THEN
	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'USUARIO TEM CARRO LOCADO';
    END IF;
    IF EXISTS( SELECT ID, ESTA_LOCADO
    FROM CARROS WHERE ID = NEW.CARROS_ID AND ESTA_LOCADO = 1)
    THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'CARRO ESTA LOCADO';
    END IF;
END$$


DELIMITER ;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
