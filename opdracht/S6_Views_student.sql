-- ------------------------------------------------------------------------
-- Data & Persistency
-- Opdracht S6: Views
--
-- (c) 2020 Hogeschool Utrecht
-- Tijmen Muller (tijmen.muller@hu.nl)
-- André Donk (andre.donk@hu.nl)
-- ------------------------------------------------------------------------


-- S6.1.
--
-- 1. Maak een view met de naam "deelnemers" waarmee je de volgende gegevens uit de tabellen inschrijvingen en uitvoering combineert:
--    inschrijvingen.cursist, inschrijvingen.cursus, inschrijvingen.begindatum, uitvoeringen.docent, uitvoeringen.locatie
CREATE OR REPLACE VIEW deelnemers AS
select inschrijvingen.cursist, inschrijvingen.cursus, inschrijvingen.begindatum, uitvoeringen.docent, uitvoeringen.locatie
from inschrijvingen
JOIN uitvoeringen ON uitvoeringen.begindatum = inschrijvingen.begindatum
    AND uitvoeringen.cursus = inschrijvingen.cursus
;

-- 2. Gebruik de view in een query waarbij je de "deelnemers" view combineert met de "personeels" view (behandeld in de les):
    CREATE OR REPLACE VIEW personeel AS
	     SELECT mnr, voorl, naam as medewerker, afd, functie
      FROM medewerkers;

select deelnemers.cursist, personeel.medewerker, deelnemers.cursus, deelnemers.begindatum, deelnemers.docent, deelnemers.locatie
from deelnemers
JOIN personeel ON personeel.mnr = deelnemers.cursist
;
    
-- 3. Is de view "deelnemers" updatable ? Waarom ?
-- Nee, want de view is niet updatable omdat de view niet aan een tabel is gekoppeld. De view is een combinatie van twee tabellen.


-- S6.2.
--
-- 1. Maak een view met de naam "dagcursussen". Deze view dient de gegevens op te halen: 
--      code, omschrijving en type uit de tabel curssussen met als voorwaarde dat de lengte = 1. Toon aan dat de view werkt. 
CREATE OR REPLACE VIEW dagcursussen AS
select code, omschrijving, type
from cursussen
where lengte = 1
;

-- 2. Maak een tweede view met de naam "daguitvoeringen". 
--    Deze view dient de uitvoeringsgegevens op te halen voor de "dagcurssussen" (gebruik ook de view "dagcursussen"). Toon aan dat de view werkt
CREATE OR REPLACE VIEW daguitvoeringen AS
select uitvoeringen.cursus, dagcursussen.omschrijving, dagcursussen.type, uitvoeringen.begindatum, uitvoeringen.docent, uitvoeringen.locatie
from uitvoeringen
join dagcursussen on dagcursussen.code = uitvoeringen.cursus
;
-- 3. Verwijder de views en laat zien wat de verschillen zijn bij DROP view <viewnaam> CASCADE en bij DROP view <viewnaam> RESTRICT
DROP view dagcursussen CASCADE;
DROP view daguitvoeringen RESTRICT;

-- De cascade optie verwijdert alle views die afhankelijk zijn van de view die je wilt verwijderen.
-- In dit voorbeeld verwijdert de cascade optie ook de view daguitvoeringen omdat deze afhankelijk is van de view dagcursussen.
-- Daarom faalt de tweede drop opdracht omdat de view daguitvoeringen al verwijderd is.


