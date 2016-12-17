DROP TABLE IF EXISTS PENALISES;
DROP TABLE IF EXISTS COMPORTE;
DROP TABLE IF EXISTS CLASSEMENT;
DROP TABLE IF EXISTS COMPETITION;
DROP TABLE IF EXISTS SKIEUR;
DROP TABLE IF EXISTS SPECIALITE;
DROP TABLE IF EXISTS STATION;


CREATE TABLE STATION (
  idStation SERIAL,
  nomStation VARCHAR(20),
  altitude INT,
  pays VARCHAR(20),
  CONSTRAINT pkStation PRIMARY KEY(idStation)
);

CREATE TABLE SPECIALITE (
  idSpecialite SERIAL,
  libelleSpecialite VARCHAR(40),
  CONSTRAINT pkSpecialite PRIMARY KEY(idSpecialite)
);

CREATE TABLE SKIEUR (
  noSkieur SERIAL,
  nomSkieur VARCHAR(20),
  idSpecialite INT,
  idStation INT,
  CONSTRAINT pkSkieur PRIMARY KEY(noSkieur),
  CONSTRAINT fkSkieurSpecialite FOREIGN KEY (idSpecialite) REFERENCES SPECIALITE(idSpecialite),
  CONSTRAINT fkSkieurStation FOREIGN KEY (idStation) REFERENCES STATION(idStation)
);

CREATE TABLE COMPETITION (
  idCompet SERIAL,
  libelleCompet VARCHAR(40),
  dateComp DATE,
  idStation INT,
  CONSTRAINT pkCompetition PRIMARY KEY(idCompet),
  CONSTRAINT fkCompetitionStation FOREIGN KEY (idStation) REFERENCES STATION(idStation)
);

CREATE TABLE CLASSEMENT (
  noSkieur INT,
  idCompet INT,
  classement INT,
  CONSTRAINT pkClassement PRIMARY KEY(noSkieur, idCompet),
  CONSTRAINT fkClassementSkieur FOREIGN KEY (noSkieur) REFERENCES SKIEUR(noSkieur),
  CONSTRAINT fkClassementCompetition FOREIGN KEY (idCompet) REFERENCES COMPETITION(idCompet)
);

CREATE TABLE COMPORTE (
  idCompet INT,
  idSpecialite INT,
  CONSTRAINT pkComporte PRIMARY KEY(idCompet, idSpecialite),
  CONSTRAINT fkComporteCompetition FOREIGN KEY (idCompet) REFERENCES COMPETITION(idCompet),
  CONSTRAINT fkComporteSpecialite FOREIGN KEY (idSpecialite) REFERENCES SPECIALITE(idSpecialite)
);

CREATE TABLE PENALISES (
	noSkieur INT,
	idCompet INT,
	CONSTRAINT pkPenalises PRIMARY KEY(noSkieur, idCompet),
  	CONSTRAINT fkPenalisesSkieur FOREIGN KEY (noSkieur) REFERENCES SKIEUR(noSkieur),
  	CONSTRAINT fkPenalisesCompetition FOREIGN KEY (idCompet) REFERENCES COMPETITION(idCompet)
);




insert into STATION values(default, 'Tignes', 2000, 'France');
insert into STATION values(default, 'Les Ménuires', 1800, 'France');
insert into STATION values(default, 'Les Arcs', 2000, 'France');
insert into STATION values(default, 'La Plagne', 2000, 'France');

insert into SPECIALITE values(default,'slalom');
insert into SPECIALITE values(default,'descente');
insert into SPECIALITE values(default,'slalom géant');

insert into SKIEUR values(default,'skieur1',1,1);
insert into SKIEUR values(default,'skieur2',1,2);
insert into SKIEUR values(default,'skieur3',2,1);
insert into SKIEUR values(default,'skieur4',2,3);
insert into SKIEUR values(default,'skieur5',2,1);
insert into SKIEUR values(default,'skieur6',3,2);

insert into COMPETITION values(default, 'compet1','2014-09-01',1);
insert into COMPETITION values(default, 'compet2','02/09/2014',1);
insert into COMPETITION values(default, 'compet3','2014-09-03',2);
insert into COMPETITION values(default, 'compet4','2014-09-04',2);
insert into COMPETITION values(default, 'compet5','2014-09-05',2);
insert into COMPETITION values(default, 'compet6','2014-09-06',3);

insert into CLASSEMENT values (1,1,1);
insert into CLASSEMENT values (2,1,2);
insert into CLASSEMENT values (3,1,4);
insert into CLASSEMENT values (4,1,3);
insert into CLASSEMENT values (1,2,1);
insert into CLASSEMENT values (2,2,2);
insert into CLASSEMENT values (3,2,3);
insert into CLASSEMENT values (4,2,4);
insert into CLASSEMENT values (5,2,5);
insert into CLASSEMENT values (6,3,1);
insert into CLASSEMENT values (1,3,2);

insert into PENALISES values (6,3);
insert into PENALISES values (1,2);


-- Fonction qui calcule et qui retourne l'altitude moyenne des stations
CREATE OR REPLACE FUNCTION calculMoyenneAltitude () RETURNS float AS
$$
  DECLARE
    	resultat float ;
          
    BEGIN
        SELECT INTO  resultat AVG(STATION.altitude) AS altitudeMoyenne
        FROM STATION;

        RETURN resultat;
    END;
$$
LANGUAGE 'plpgsql';

--  Fonction qui formalise (1ère lettre majuscule le reste en minuscule) un nom passé en paramètre. Ex : DUPONT -> Dupont
CREATE OR REPLACE FUNCTION formaliseNom (nom VARCHAR) RETURNS VARCHAR AS
$$
	DECLARE
      	nomFini VARCHAR := INITCAP(nom);
  	BEGIN
      	RETURN nomFini;
 	END;
$$
LANGUAGE 'plpgsql';

--  Fonction qui formalise le nom de tous les skieurs. Cette fonction retournera le nombre de lignes traitées
CREATE OR REPLACE FUNCTION formaliseSkieur () RETURNS VARCHAR AS
$$
  	DECLARE
     	i int :=0;
      	curs CURSOR FOR 
          	SELECT SKIEUR.nomSkieur as nomSkieur
         	FROM SKIEUR;
	BEGIN
     	FOR resultat in curs LOOP
        	UPDATE SKIEUR SET nomSkieur = (formaliseNom(resultat.nomSkieur));
        	i:=i+1;
     	END LOOP;
        
        RETURN ('Le nombre de ligne est de : '||i);
    END;
$$
LANGUAGE 'plpgsql';

-- Fonction qui déclasse les skieurs présents dans la table PENALISÉS
CREATE OR REPLACE FUNCTION declasseSkieurPenalises () RETURNS void AS
$$
DECLARE
	x INTEGER := 0;
	y INTEGER := 0;
	curseur1 CURSOR FOR 
		SELECT PENALISES.idCompet
		FROM PENALISES
		GROUP BY PENALISES.idCompet
		ORDER BY PENALISES.idCompet;

BEGIN 
	FOR curseurRecord in curseur1 LOOP
		x := curseurRecord.idCompet;
		y := idCompetPenalise(x);
		SELECT updateClassementAvecSkieurPenalises(x, y);
	END LOOP;
END; 
$$
LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION idCompetPenalise (id int) RETURNS int AS
$$
DECLARE
	curseur2 CURSOR FOR 
		SELECT COUNT(CLASSEMENT.noSkieur) AS nbDeParticipant
		FROM CLASSEMENT
		WHERE CLASSEMENT.idCompet = id;
BEGIN
	FOR curseurRecord in curseur2 LOOP
		RETURN curseurRecord.nbDeParticipant;
	END LOOP;
END; 
$$
LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION updateClassementAvecSkieurPenalises (x int, y int) RETURNS void AS
$$
DECLARE
	z INTEGER := 0;
	curseur3 CURSOR FOR 
		SELECT PENALISES.noSkieur
		FROM PENALISES 
		WHERE PENALISES.idCompet = x;

BEGIN 
	FOR curseurRecord in curseur3 LOOP
		z := curseurRecord.noSkieur;

		UPDATE CLASSEMENT set CLASSEMENT.classement = (y + 1)
		WHERE CLASSEMENT.noSkieur = z
		AND CLASSEMENT.idCompet = x;
	END LOOP;
END; 
$$
LANGUAGE 'plpgsql';

-- Trigger de vérification lors de l’insertion d’une nouvelle station. Ce trigger vérifiera qu’aucune
-- donnée n’est NULL et que l’altitude est bien une valeur positive.

CREATE OR REPLACE FUNCTION Station_stamp() RETURNS TRIGGER AS 
$station_stamp$
BEGIN
  	-- Verifie que nomstation et pays sont donnés
    IF NEW.nomStation IS NULL THEN
        RAISE EXCEPTION 'nomStation ne peut pas être NULL';
    END IF;
    IF NEW.pays IS NULL THEN
        RAISE EXCEPTION 'pays ne peut pas être NULL ';
    END IF;

    IF NEW.altitude < 0 THEN
        RAISE EXCEPTION '% ne peut pas avoir une altitude negative', NEW.nomStation;
    END IF;
    RETURN NEW; -- le résultat est ignoré car il s'agit d'un trigger AFTER
END;
$station_stamp$ LANGUAGE plpgsql;

CREATE TRIGGER station_stamp
    BEFORE INSERT ON STATION
    FOR EACH ROW EXECUTE PROCEDURE Station_stamp();

select * from classement;