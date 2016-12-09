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
  CONSTRAINT fkcomporteSpecialite FOREIGN KEY (idSpecialite) REFERENCES SPECIALITE(idSpecialite),
  CONSTRAINT fkcomporteStation FOREIGN KEY (idStation) REFERENCES STATION(idStation)
);

CREATE TABLE COMPETITION (
  idCompet SERIAL,
  libelleCompet VARCHAR(40),
  dateComp DATE,
  idStation INT,
  CONSTRAINT pkCompetition PRIMARY KEY(idCompet),
  CONSTRAINT fkcomporteStation FOREIGN KEY (idStation) REFERENCES STATION(idStation)
);

CREATE TABLE CLASSEMENT (
  noSkieur INT,
  idCompet INT,
  classement INT,
  CONSTRAINT pkClassement PRIMARY KEY(noSkieur, idCompet),
  CONSTRAINT fkcomporteSkieur FOREIGN KEY (noSkieur) REFERENCES SKIEUR(noSkieur),
  CONSTRAINT fkcomporteCompetition FOREIGN KEY (idCompet) REFERENCES COMPETITION(idCompet)
);

CREATE TABLE COMPORTE (
  idCompet INT,
  idSpecialite INT,
  CONSTRAINT pkComporte PRIMARY KEY(idCompet, idSpecialite),
  CONSTRAINT fkcomporteCompetition FOREIGN KEY (idCompet) REFERENCES COMPETITION(idCompet),
  CONSTRAINT fkcomporteSpecialite FOREIGN KEY (idSpecialite) REFERENCES SPECIALITE(idSpecialite)
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