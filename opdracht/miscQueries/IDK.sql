SELECT *
FROM cursussen
JOIN uitvoeringen ON cursussen.code = uitvoeringen.cursus
WHERE uitvoeringen.locatie = 'UTRECHT' OR uitvoeringen.locatie = 'MAASTRICHT';

SELECT * from uitvoeringen
JOIN medewerkers ON medewerkers.mnr = uitvoeringen.docent

SELECT * FROM medewerkers
WHERE functie = 'TRAINER';

select * from schalen
