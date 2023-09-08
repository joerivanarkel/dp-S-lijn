SELECT * FROM medewerkers;

SELECT * FROM afdelingen;

SELECT medewerkers.naam, * FROM afdelingen
    JOIN medewerkers ON afdelingen.hoofd = medewerkers.mnr;