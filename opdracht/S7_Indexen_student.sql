-- ------------------------------------------------------------------------
-- Data & Persistency
-- Opdracht S7: Indexen
--
-- (c) 2020 Hogeschool Utrecht
-- Tijmen Muller (tijmen.muller@hu.nl)
-- André Donk (andre.donk@hu.nl)
-- ------------------------------------------------------------------------
-- LET OP, zoals in de opdracht op Canvas ook gezegd kun je informatie over
-- het query plan vinden op: https://www.postgresql.org/docs/current/using-explain.html


-- S7.1.
--
-- Je maakt alle opdrachten in de 'sales' database die je hebt aangemaakt en gevuld met
-- de aangeleverde data (zie de opdracht op Canvas).

-- Voer het voorbeeld uit wat in de les behandeld is:
-- 1. Voer het volgende EXPLAIN statement uit:
EXPLAIN SELECT * FROM order_lines WHERE stock_item_id = 9;
--    Bekijk of je het resultaat begrijpt. Kopieer het explain plan onderaan de opdracht

-- 2. Voeg een index op stock_item_id toe:
CREATE INDEX ord_lines_si_id_idx ON order_lines (stock_item_id);

-- 3. Analyseer opnieuw met EXPLAIN hoe de query nu uitgevoerd wordt
--    Kopieer het explain plan onderaan de opdracht
EXPLAIN SELECT * FROM order_lines WHERE stock_item_id = 9;

-- 4. Verklaar de verschillen. Schrijf deze hieronder op.
-- Er is nu een index op stock_item_id. Daaardoor hoeft de database niet meer de hele tabel te doorzoeken


-- S7.2.
--
-- 1. Maak de volgende twee query’s:
-- 	  A. Toon uit de order tabel de order met order_id = 73590
EXPLAIN SELECT * FROM orders WHERE order_id = 73590;

-- 	  B. Toon uit de order tabel de order met customer_id = 1028
EXPLAIN SELECT * FROM orders WHERE customer_id = 1028;

-- 2. Analyseer met EXPLAIN hoe de query’s uitgevoerd worden en kopieer het explain plan onderaan de opdracht

-- 3. Verklaar de verschillen en schrijf deze op
-- Bij de eerste query wordt er gebruik gemaakt van een index, omdat er standaard een index op de primary key wordt aangemaakt.
-- Bij de tweede query wordt er geen gebruik gemaakt van een index, omdat er geen index is op customer_id

-- 4. Voeg een index toe, waarmee query B versneld kan worden
CREATE INDEX ord_cust_id_idx ON orders (customer_id);

-- 5. Analyseer met EXPLAIN en kopieer het explain plan onder de opdracht

-- 6. Verklaar de verschillen en schrijf hieronder op
-- Er wordt nu wel gebruik gemaakt van een index om de query te versnellen

EXPLAIN SELECT * FROM orders WHERE order_id = 73590;
EXPLAIN SELECT * FROM orders WHERE customer_id = 1028;


-- S7.3.A
--
-- Het blijkt dat customers regelmatig klagen over trage bezorging van hun bestelling.
-- Het idee is dat verkopers misschien te lang wachten met het invoeren van de bestelling in het systeem.
-- Daar willen we meer inzicht in krijgen.
-- We willen alle orders (order_id, order_date, salesperson_person_id (als verkoper),
--    het verschil tussen expected_delivery_date en order_date (als levertijd),  
--    en de bestelde hoeveelheid van een product zien (quantity uit order_lines).
-- Dit willen we alleen zien voor een bestelde hoeveelheid van een product > 250
--   (we zijn nl. als eerste geïnteresseerd in grote aantallen want daar lijkt het vaker mis te gaan)
-- En verder willen we ons focussen op verkopers wiens bestellingen er gemiddeld langer over doen.
-- De meeste bestellingen kunnen binnen een dag bezorgd worden, sommige binnen 2-3 dagen.
-- Het hele bestelproces is er op gericht dat de gemiddelde bestelling binnen 1.45 dagen kan worden bezorgd.
-- We willen in onze query dan ook alleen de verkopers zien wiens gemiddelde levertijd 
--  (expected_delivery_date - order_date) over al zijn/haar bestellingen groter is dan 1.45 dagen.
-- Maak om dit te bereiken een subquery in je WHERE clause.
-- Sorteer het resultaat van de hele geheel op levertijd (desc) en verkoper.
-- 1. Maak hieronder deze query (als je het goed doet zouden er 377 rijen uit moeten komen, en het kan best even duren...)

SELECT orders.order_id, orders.order_date, orders.salesperson_person_id, 
        (orders.expected_delivery_date - orders.order_date) AS levertijd, 
        order_lines.quantity
FROM orders
INNER JOIN order_lines ON orders.order_id = order_lines.order_id
WHERE order_lines.quantity > 250
AND orders.salesperson_person_id IN (
    SELECT orders.salesperson_person_id
    FROM orders
    GROUP BY orders.salesperson_person_id
    HAVING AVG(orders.expected_delivery_date - orders.order_date) > 1.45
)
ORDER BY levertijd DESC, orders.salesperson_person_id;


-- S7.3.B
--
-- 1. Vraag het EXPLAIN plan op van je query (kopieer hier, onder de opdracht)

EXPLAIN SELECT orders.order_id, orders.order_date, orders.salesperson_person_id, 
        (orders.expected_delivery_date - orders.order_date) AS levertijd, 
        order_lines.quantity
FROM orders
INNER JOIN order_lines ON orders.order_id = order_lines.order_id
WHERE order_lines.quantity > 250
AND orders.salesperson_person_id IN (
    SELECT orders.salesperson_person_id
    FROM orders
    GROUP BY orders.salesperson_person_id
    HAVING AVG(orders.expected_delivery_date - orders.order_date) > 1.45
)
ORDER BY levertijd DESC, orders.salesperson_person_id;

-- 2. Kijk of je met 1 of meer indexen de query zou kunnen versnellen

CREATE INDEX ord_sales_id_idx ON orders (salesperson_person_id);
CREATE INDEX ord_exp_del_idx ON orders (expected_delivery_date);

-- 3. Maak de index(en) aan en run nogmaals het EXPLAIN plan (kopieer weer onder de opdracht) 
-- 4. Wat voor verschillen zie je? Verklaar hieronder.





EXPLAIN SELECT orders.order_id, orders.order_date, orders.salesperson_person_id, 
        (orders.expected_delivery_date - orders.order_date) AS levertijd, 
        order_lines.quantity
FROM orders
INNER JOIN order_lines ON orders.order_id = order_lines.order_id
WHERE order_lines.quantity > 250
AND orders.salesperson_person_id IN (
    SELECT orders.salesperson_person_id
    FROM orders
    GROUP BY orders.salesperson_person_id
    HAVING AVG(orders.expected_delivery_date - orders.order_date) > 1.45
)
ORDER BY levertijd DESC, orders.salesperson_person_id;

-- S7.3.C
--
-- Zou je de query ook heel anders kunnen schrijven om hem te versnellen?

-- 1. Schrijf hieronder je nieuwe query op


-- Revert to original state
DROP INDEX ord_lines_si_id_idx;
DROP INDEX ord_cust_id_idx;

DROP INDEX ord_sales_id_idx;
DROP INDEX ord_exp_del_idx;