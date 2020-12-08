1. pax_info - все пассажиры 

CREATE MATERIALIZED VIEW public.pax_info
TABLESPACE pg_default
AS
 WITH paxes AS (
         SELECT DISTINCT aggregator_users.last_name,
            aggregator_users.first_name,
            NULL::text AS second_name,
            NULL::text AS document,
            NULL::date AS birth_date
           FROM aggregator_users
          WHERE (NOT (aggregator_users.flight_id IN ( SELECT same_ag.flight_id
                   FROM same_ag)))
        UNION
         SELECT DISTINCT bp.last_name,
            bp.first_name,
            NULL::text AS second_name,
            NULL::text AS document,
            NULL::date AS birth_date
           FROM boarding_pass bp
          WHERE (NOT (bp.pass_id IN ( SELECT same_bp.pass_id
                   FROM same_bp)))
        UNION
        ( SELECT DISTINCT ON (t.document) t.last_name,
            t.first_name,
            t.second_name,
            t.document,
            t.birth_date
           FROM ( SELECT DISTINCT f.last_name,
                    f.first_name,
                    f.second_name,
                    f.document,
                    f.birth_date
                   FROM flights f
                UNION
                 SELECT DISTINCT boarding_data.last_name,
                    boarding_data.first_name,
                    boarding_data.second_name,
                    boarding_data.document,
                    boarding_data.birth_date
                   FROM boarding_data) t
          ORDER BY t.document, t.second_name DESC)
  ORDER BY 1, 2, 3
        )
 SELECT row_number() OVER (ORDER BY paxes.last_name, paxes.first_name) AS pax_id,
    paxes.last_name,
    paxes.first_name,
    paxes.second_name,
    paxes.birth_date,
    paxes.document
   FROM paxes
  ORDER BY (row_number() OVER (ORDER BY paxes.last_name, paxes.first_name))
WITH DATA;

ALTER TABLE public.pax_info
    OWNER TO postgres;


2. pax_f - связь pax_id с таблицей с перелётами flights 

CREATE MATERIALIZED VIEW public.pax_f
TABLESPACE pg_default
AS
 SELECT p.pax_id,
    f.last_name,
    f.first_name,
    f.second_name,
    f.document,
    f.depart_date,
    f.flight_number,
    f.from_airport,
    f.to_airport,
    f.baggage_count,
    f.meal,
    f.agent,
    f.class
   FROM pax_info p,
    flights f
  WHERE ((p.last_name = f.last_name) AND (p.first_name = f.first_name) AND (p.document = f.document))
WITH DATA;

ALTER TABLE public.pax_f
    OWNER TO postgres;


3. pax_bp

CREATE MATERIALIZED VIEW public.pax_bp
TABLESPACE pg_default
AS
 SELECT p.pax_id,
    bp.last_name,
    bp.first_name,
    NULL::text AS second_name,
    bp.class,
    bp.date,
    bp.flight_number,
    bp.from_airport,
    bp.to_airport
   FROM pax_info p,
    boarding_pass bp
  WHERE ((p.last_name = bp.last_name) AND (p.first_name = bp.first_name) AND (p.document IS NULL) AND (p.birth_date IS NULL))
WITH DATA;

ALTER TABLE public.pax_bp
    OWNER TO postgres;


4. pax_bd

CREATE MATERIALIZED VIEW public.pax_bd
TABLESPACE pg_default
AS
 SELECT p.pax_id,
    bd.last_name,
    bd.first_name,
    bd.second_name,
    bd.document,
    bd.flight_number,
    bd.date,
    bd.to_city,
    bd.baggage
   FROM pax_info p,
    boarding_data bd
  WHERE ((p.last_name = bd.last_name) AND (p.first_name = bd.first_name) AND (p.document = bd.document))
WITH DATA;

ALTER TABLE public.pax_bd
    OWNER TO postgres;


5. pax_ag

CREATE MATERIALIZED VIEW public.pax_ag
TABLESPACE pg_default
AS
 SELECT p.pax_id,
    ag.last_name,
    ag.first_name,
    ag.card_number,
    ag.bonus_programm,
    ag.flight_number,
    ag.date,
    ag.from_airport,
    ag.to_airport
   FROM pax_info p,
    aggregator_users ag
  WHERE ((p.document IS NULL) AND (p.birth_date IS NULL) AND (ag.last_name = p.last_name) AND (ag.first_name = p.first_name) AND (NOT (ag.flight_id IN ( SELECT same_ag.flight_id
           FROM same_ag))))
UNION
 SELECT p.pax_id,
    ag.last_name,
    ag.first_name,
    ag.card_number,
    ag.bonus_programm,
    ag.flight_number,
    ag.date,
    ag.from_airport,
    ag.to_airport
   FROM pax_info p,
    aggregator_users ag,
    same_ag sa
  WHERE ((sa.flight_id = ag.flight_id) AND (ag.last_name = p.last_name) AND (ag.first_name = p.first_name) AND (sa.document = p.document))
WITH DATA;

ALTER TABLE public.pax_ag
    OWNER TO postgres;


6. from_forum

CREATE MATERIALIZED VIEW public.from_forum
TABLESPACE pg_default
AS
 SELECT DISTINCT t.pax_id,
    t.last_name,
    t.first_name,
    t.flight_number
   FROM ( SELECT f.pax_id,
            fr.last_name,
            fr.first_name,
            fr.flight_number
           FROM forum_profiles fr,
            pax_f f
          WHERE ((fr.last_name = f.last_name) AND (fr.first_name = f.first_name) AND (fr.flight_number = f.flight_number))
        UNION
         SELECT bd.pax_id,
            fr.last_name,
            fr.first_name,
            fr.flight_number
           FROM forum_profiles fr,
            pax_bd bd
          WHERE ((fr.last_name = bd.last_name) AND (fr.first_name = bd.first_name) AND (fr.flight_number = bd.flight_number))
        UNION
         SELECT bp.pax_id,
            fr.last_name,
            fr.first_name,
            fr.flight_number
           FROM forum_profiles fr,
            pax_bp bp
          WHERE ((fr.last_name = bp.last_name) AND (fr.first_name = bp.first_name) AND (fr.flight_number = bp.flight_number))) t
  ORDER BY t.pax_id, t.last_name, t.first_name
WITH DATA;

ALTER TABLE public.from_forum
    OWNER TO postgres;


7. pax_bonus

CREATE MATERIALIZED VIEW public.pax_bonus
TABLESPACE pg_default
AS
 SELECT pax_info.pax_id,
        CASE
            WHEN (pax_info.pax_id IN ( SELECT pax_ag.pax_id
               FROM pax_ag)) THEN 'Yes'::text
            ELSE 'No'::text
        END AS bonus_programm
   FROM pax_info
WITH DATA;

ALTER TABLE public.pax_bonus
    OWNER TO postgres;



8. pax_forum

CREATE MATERIALIZED VIEW public.pax_forum
TABLESPACE pg_default
AS
 SELECT pax_info.pax_id,
        CASE
            WHEN (pax_info.pax_id IN ( SELECT from_forum.pax_id
               FROM from_forum)) THEN 'Yes'::text
            ELSE 'No'::text
        END AS forum_profile
   FROM pax_info
WITH DATA;

ALTER TABLE public.pax_forum
    OWNER TO postgres;



9. flights_country

CREATE MATERIALIZED VIEW public.flights_country
TABLESPACE pg_default
AS
 WITH pax_flight AS (
         SELECT DISTINCT ON (t.last_name, t.first_name, t.flight_number, t.date) t.pax_id,
            t.first_name,
            t.last_name,
            t.second_name,
            t.flight_number,
            t.from_country,
            t.to_country,
            t.date
           FROM ( SELECT pax_bd.pax_id,
                    pax_bd.first_name,
                    pax_bd.last_name,
                    pax_bd.second_name,
                    pax_bd.flight_number,
                    r.from_country,
                    r.to_country,
                    pax_bd.date
                   FROM pax_bd,
                    russian_flights r
                  WHERE ((r.flight_number = pax_bd.flight_number) AND (r.to_city = pax_bd.to_city))
                UNION
                 SELECT pax_f.pax_id,
                    pax_f.first_name,
                    pax_f.last_name,
                    pax_f.second_name,
                    pax_f.flight_number,
                    ad1.country AS from_country,
                    ad2.country AS to_country,
                    pax_f.depart_date
                   FROM pax_f,
                    address ad1,
                    address ad2
                  WHERE ((ad1.airport = pax_f.from_airport) AND (ad2.airport = pax_f.to_airport))
                UNION
                 SELECT pax_bp.pax_id,
                    pax_bp.first_name,
                    pax_bp.last_name,
                    pax_bp.second_name,
                    pax_bp.flight_number,
                    ad1.country AS from_country,
                    ad2.country AS to_country,
                    pax_bp.date
                   FROM pax_bp,
                    address ad1,
                    address ad2
                  WHERE ((ad1.airport = pax_bp.from_airport) AND (ad2.airport = pax_bp.to_airport))
                UNION
                 SELECT pax_ag.pax_id,
                    pax_ag.first_name,
                    pax_ag.last_name,
                    NULL::text AS second_name,
                    pax_ag.flight_number,
                    ad1.country AS from_country,
                    ad2.country AS to_country,
                    pax_ag.date
                   FROM pax_ag,
                    address ad1,
                    address ad2
                  WHERE ((ad1.airport = pax_ag.from_airport) AND (ad2.airport = pax_ag.to_airport))) t
          ORDER BY t.last_name, t.first_name, t.flight_number, t.date
        )
 SELECT row_number() OVER (ORDER BY pax_flight.last_name, pax_flight.first_name) AS paxflight_id,
    pax_flight.pax_id,
    pax_flight.last_name,
    pax_flight.first_name,
    pax_flight.second_name,
    pax_flight.flight_number,
    pax_flight.from_country,
    pax_flight.to_country,
    pax_flight.date
   FROM pax_flight
  ORDER BY pax_flight.pax_id, pax_flight.last_name, pax_flight.first_name, pax_flight.second_name, pax_flight.flight_number, pax_flight.from_country, pax_flight.to_country, pax_flight.date
WITH DATA;

ALTER TABLE public.flights_country
    OWNER TO postgres;



10. all_flights

CREATE MATERIALIZED VIEW public.all_flights
TABLESPACE pg_default
AS
 WITH pax_flight AS (
         SELECT DISTINCT ON (t.last_name, t.first_name, t.flight_number, t.date) t.pax_id,
            t.first_name,
            t.last_name,
            t.second_name,
            t.flight_number,
            t.date
           FROM ( SELECT pax_bd.pax_id,
                    pax_bd.first_name,
                    pax_bd.last_name,
                    pax_bd.second_name,
                    pax_bd.flight_number,
                    pax_bd.date
                   FROM pax_bd
                UNION
                 SELECT pax_f.pax_id,
                    pax_f.first_name,
                    pax_f.last_name,
                    pax_f.second_name,
                    pax_f.flight_number,
                    pax_f.depart_date
                   FROM pax_f
                UNION
                 SELECT pax_bp.pax_id,
                    pax_bp.first_name,
                    pax_bp.last_name,
                    pax_bp.second_name,
                    pax_bp.flight_number,
                    pax_bp.date
                   FROM pax_bp
                UNION
                 SELECT pax_ag.pax_id,
                    pax_ag.first_name,
                    pax_ag.last_name,
                    NULL::text AS second_name,
                    pax_ag.flight_number,
                    pax_ag.date
                   FROM pax_ag) t
          ORDER BY t.last_name, t.first_name, t.flight_number, t.date
        )
 SELECT row_number() OVER (ORDER BY pax_flight.last_name, pax_flight.first_name) AS allflight_id,
    pax_flight.pax_id,
    pax_flight.last_name,
    pax_flight.first_name,
    pax_flight.second_name,
    pax_flight.flight_number,
    pax_flight.date
   FROM pax_flight
  ORDER BY pax_flight.pax_id, pax_flight.last_name, pax_flight.first_name, pax_flight.date
WITH DATA;

ALTER TABLE public.all_flights
    OWNER TO postgres;



11. flights_count

CREATE MATERIALIZED VIEW public.flights_count
TABLESPACE pg_default
AS
 SELECT p.pax_id,
    p.last_name,
    p.first_name,
    p.second_name,
    count(
        CASE
            WHEN ((pf.from_country = 'Russian Federation'::text) AND (pf.to_country <> 'Russian Federation'::text)) THEN 1
            ELSE NULL::integer
        END) AS from_russia,
    count(
        CASE
            WHEN ((pf.from_country <> 'Russian Federation'::text) AND (pf.to_country <> 'Russian Federation'::text)) THEN 1
            ELSE NULL::integer
        END) AS not_in_russia
   FROM pax_info p,
    flights_country pf
  WHERE (p.pax_id = pf.pax_id)
  GROUP BY p.pax_id, p.last_name, p.first_name, p.second_name
  ORDER BY (count(
        CASE
            WHEN ((pf.from_country = 'Russian Federation'::text) AND (pf.to_country <> 'Russian Federation'::text)) THEN 1
            ELSE NULL::integer
        END)) DESC, (count(pf.paxflight_id)) DESC, (count(
        CASE
            WHEN ((pf.from_country <> 'Russian Federation'::text) AND (pf.to_country <> 'Russian Federation'::text)) THEN 1
            ELSE NULL::integer
        END)) DESC
WITH DATA;

ALTER TABLE public.flights_count
    OWNER TO postgres;


12. all_flights_count

CREATE MATERIALIZED VIEW public.all_flights_count
TABLESPACE pg_default
AS
 SELECT DISTINCT p.pax_id,
    p.last_name,
    p.first_name,
    p.second_name,
    count(af.allflight_id) AS flights
   FROM all_flights af,
    pax_info p
  WHERE (p.pax_id = af.pax_id)
  GROUP BY p.pax_id, p.last_name, p.first_name, p.second_name
  ORDER BY (count(af.allflight_id)) DESC
WITH DATA;

ALTER TABLE public.all_flights_count
    OWNER TO postgres;


13. baggage

CREATE MATERIALIZED VIEW public.baggage
TABLESPACE pg_default
AS
 SELECT t.pax_id,
    t.last_name,
    t.first_name,
    t.document,
    sum(t.flights) AS flights,
    sum(t.baggage) AS baggage,
    (sum(t.flights) - sum(t.baggage)) AS baggage_diff
   FROM ( SELECT bd.pax_id,
            bd.last_name,
            bd.first_name,
            bd.document,
            count(bd.pax_id) AS flights,
            count(
                CASE
                    WHEN (bd.baggage IS NULL) THEN NULL::integer
                    ELSE 1
                END) AS baggage
           FROM pax_bd bd
          GROUP BY bd.pax_id, bd.last_name, bd.first_name, bd.document
        UNION
         SELECT f.pax_id,
            f.last_name,
            f.first_name,
            f.document,
            count(f.pax_id) AS flights,
            count(
                CASE
                    WHEN ((f.baggage_count = '0PC'::text) OR (f.baggage_count IS NULL)) THEN NULL::integer
                    ELSE 1
                END) AS baggage
           FROM pax_f f
          GROUP BY f.pax_id, f.last_name, f.first_name, f.document) t
  GROUP BY t.pax_id, t.last_name, t.first_name, t.document
  ORDER BY (sum(t.flights) - sum(t.baggage)) DESC, t.pax_id
WITH DATA;

ALTER TABLE public.baggage
    OWNER TO postgres;


14. class

CREATE MATERIALIZED VIEW public.class
TABLESPACE pg_default
AS
 SELECT t.pax_id,
    t.last_name,
    t.first_name,
    t.second_name,
    count(t.flight_number) AS flights,
    count(
        CASE t.class
            WHEN 'Y'::text THEN 1
            ELSE NULL::integer
        END) AS economy_class,
    count(
        CASE t.class
            WHEN 'P'::text THEN 1
            ELSE NULL::integer
        END) AS premium_economy,
    count(
        CASE t.class
            WHEN 'J'::text THEN 1
            ELSE NULL::integer
        END) AS business_class,
    count(
        CASE t.class
            WHEN 'A'::text THEN 1
            ELSE NULL::integer
        END) AS first_class
   FROM ( SELECT pax_f.pax_id,
            pax_f.last_name,
            pax_f.first_name,
            pax_f.second_name,
            pax_f.flight_number,
            pax_f.class
           FROM pax_f
        UNION
         SELECT pax_bp.pax_id,
            pax_bp.last_name,
            pax_bp.first_name,
            NULL::text AS text,
            pax_bp.flight_number,
            pax_bp.class
           FROM pax_bp
          WHERE (NOT (pax_bp.pax_id IN ( SELECT pax_f.pax_id
                   FROM pax_f)))) t
  GROUP BY t.pax_id, t.last_name, t.first_name, t.second_name
  ORDER BY (count(t.flight_number)) DESC
WITH DATA;

ALTER TABLE public.class
    OWNER TO postgres;



15. meal

CREATE MATERIALIZED VIEW public.meal
TABLESPACE pg_default
AS
 SELECT pax_f.pax_id,
    pax_f.last_name,
    pax_f.first_name,
    count(pax_f.last_name) AS flights_count,
    count(
        CASE
            WHEN (pax_f.meal IS NULL) THEN NULL::integer
            ELSE 1
        END) AS meal_count,
    (count(pax_f.last_name) - count(
        CASE
            WHEN (pax_f.meal IS NULL) THEN NULL::integer
            ELSE 1
        END)) AS meal_diff
   FROM pax_f
  GROUP BY pax_f.pax_id, pax_f.last_name, pax_f.first_name
  ORDER BY (count(pax_f.last_name) - count(
        CASE
            WHEN (pax_f.meal IS NULL) THEN NULL::integer
            ELSE 1
        END)) DESC, pax_f.pax_id
WITH DATA;

ALTER TABLE public.meal
    OWNER TO postgres;


16. summary

CREATE MATERIALIZED VIEW public.summary
TABLESPACE pg_default
AS
 SELECT p.pax_id,
    p.last_name,
    p.first_name,
    p.second_name,
    p.birth_date,
    date_part('year'::text, age(('2020-10-20'::date)::timestamp with time zone, (p.birth_date)::timestamp with time zone)) AS age,
    p.document,
    afc.flights,
    c.economy_class,
    c.premium_economy,
    c.business_class,
    c.first_class,
    fc.from_russia,
    fc.not_in_russia,
    b.baggage_diff,
    m.meal_diff,
    pf.forum_profile,
    pb.bonus_programm
   FROM (((((((pax_info p
     LEFT JOIN pax_forum pf ON ((pf.pax_id = p.pax_id)))
     LEFT JOIN pax_bonus pb ON ((pb.pax_id = p.pax_id)))
     LEFT JOIN all_flights_count afc ON ((afc.pax_id = p.pax_id)))
     LEFT JOIN flights_count fc ON ((fc.pax_id = p.pax_id)))
     LEFT JOIN baggage b ON ((b.pax_id = p.pax_id)))
     LEFT JOIN meal m ON ((m.pax_id = p.pax_id)))
     LEFT JOIN class c ON ((c.pax_id = p.pax_id)))
  ORDER BY pf.forum_profile, pb.bonus_programm, fc.from_russia DESC, fc.not_in_russia DESC, b.baggage_diff DESC, m.meal_diff DESC, p.pax_id
WITH DATA;

ALTER TABLE public.summary
    OWNER TO postgres;

