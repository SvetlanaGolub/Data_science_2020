1. address

CREATE TABLE public.address
(
    address_id integer NOT NULL,
    country text COLLATE pg_catalog."default",
    city text COLLATE pg_catalog."default",
    airport text COLLATE pg_catalog."default",
    CONSTRAINT timetable_pkey PRIMARY KEY (address_id)
)

TABLESPACE pg_default;

ALTER TABLE public.address
    OWNER to postgres;

2. aggregator_users

CREATE TABLE public.aggregator_users
(
    flight_id integer NOT NULL,
    user_id integer,
    first_name text COLLATE pg_catalog."default",
    last_name text COLLATE pg_catalog."default",
    card_number text COLLATE pg_catalog."default",
    bonus_programm text COLLATE pg_catalog."default",
    flight_number text COLLATE pg_catalog."default",
    date date,
    from_airport text COLLATE pg_catalog."default",
    to_airport text COLLATE pg_catalog."default",
    fare text COLLATE pg_catalog."default",
    CONSTRAINT "Aggregator_users_pkey" PRIMARY KEY (flight_id)
)

TABLESPACE pg_default;

ALTER TABLE public.aggregator_users
    OWNER to postgres;

3. boarding_data

CREATE TABLE public.boarding_data
(
    boarding_id integer NOT NULL,
    first_name text COLLATE pg_catalog."default" NOT NULL,
    second_name text COLLATE pg_catalog."default",
    last_name text COLLATE pg_catalog."default",
    sex text COLLATE pg_catalog."default",
    birth_date date,
    document text COLLATE pg_catalog."default",
    booking_code text COLLATE pg_catalog."default",
    ticket_number text COLLATE pg_catalog."default",
    baggage text COLLATE pg_catalog."default",
    date date,
    "time" time without time zone,
    flight_number text COLLATE pg_catalog."default",
    to_city text COLLATE pg_catalog."default",
    CONSTRAINT "Boarding_data_pkey" PRIMARY KEY (boarding_id)
)

TABLESPACE pg_default;

ALTER TABLE public.boarding_data
    OWNER to postgres;


4. boarding_pass

CREATE TABLE public.boarding_pass
(
    pass_id integer NOT NULL,
    first_name text COLLATE pg_catalog."default" NOT NULL,
    last_name text COLLATE pg_catalog."default" NOT NULL,
    from_airport text COLLATE pg_catalog."default",
    to_airport text COLLATE pg_catalog."default",
    date date,
    "time" time without time zone,
    flight_number text COLLATE pg_catalog."default",
    "e-ticket" text COLLATE pg_catalog."default",
    sequence integer,
    "PNR" text COLLATE pg_catalog."default",
    class text COLLATE pg_catalog."default",
    sex text COLLATE pg_catalog."default",
    CONSTRAINT "Boarding_pass_pkey" PRIMARY KEY (pass_id)
)

TABLESPACE pg_default;

ALTER TABLE public.boarding_pass
    OWNER to postgres;

5. flights

CREATE TABLE public.flights
(
    flight_id integer NOT NULL,
    first_name text COLLATE pg_catalog."default",
    second_name text COLLATE pg_catalog."default",
    last_name text COLLATE pg_catalog."default",
    birth_date date,
    depart_date date,
    depart_time time without time zone,
    arrival_date date,
    arrival_time time without time zone,
    flight_number text COLLATE pg_catalog."default",
    from_airport text COLLATE pg_catalog."default",
    to_airport text COLLATE pg_catalog."default",
    flight_code text COLLATE pg_catalog."default",
    "e-ticket" text COLLATE pg_catalog."default",
    document text COLLATE pg_catalog."default",
    meal text COLLATE pg_catalog."default",
    fare text COLLATE pg_catalog."default",
    baggage_count text COLLATE pg_catalog."default",
    additional_info text COLLATE pg_catalog."default",
    agent text COLLATE pg_catalog."default",
    class text COLLATE pg_catalog."default",
    info text COLLATE pg_catalog."default",
    CONSTRAINT "Flights_pkey" PRIMARY KEY (flight_id)
)

TABLESPACE pg_default;

ALTER TABLE public.flights
    OWNER to postgres;


6. forum_profiles

CREATE TABLE public.forum_profiles
(
    profile_id integer NOT NULL,
    first_name text COLLATE pg_catalog."default",
    last_name text COLLATE pg_catalog."default",
    flight_number text COLLATE pg_catalog."default",
    CONSTRAINT "Forum_profiles_pkey" PRIMARY KEY (profile_id)
)

TABLESPACE pg_default;

ALTER TABLE public.forum_profiles
    OWNER to postgres;


7. russian_flights

CREATE TABLE public.russian_flights
(
    flight_id integer NOT NULL,
    from_country text COLLATE pg_catalog."default",
    from_city text COLLATE pg_catalog."default",
    to_country text COLLATE pg_catalog."default",
    to_city text COLLATE pg_catalog."default",
    flight_number text COLLATE pg_catalog."default",
    CONSTRAINT russian_flights_pkey PRIMARY KEY (flight_id)
)

TABLESPACE pg_default;

ALTER TABLE public.russian_flights
    OWNER to postgres;
