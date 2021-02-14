--
-- PostgreSQL database dump
--

-- Dumped from database version 11.5 (Ubuntu 11.5-0ubuntu0.19.04.1)
-- Dumped by pg_dump version 11.5 (Ubuntu 11.5-0ubuntu0.19.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: music_booking; Type: DATABASE; Schema: -; Owner: music_booking
--

CREATE DATABASE music_booking WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'en_US.UTF-8' LC_CTYPE = 'en_US.UTF-8';


ALTER DATABASE music_booking OWNER TO music_booking;

\connect music_booking

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: diesel_manage_updated_at(regclass); Type: FUNCTION; Schema: public; Owner: music_booking
--

CREATE FUNCTION public.diesel_manage_updated_at(_tbl regclass) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    EXECUTE format('CREATE TRIGGER set_updated_at BEFORE UPDATE ON %s
                    FOR EACH ROW EXECUTE PROCEDURE diesel_set_updated_at()', _tbl);
END;
$$;


ALTER FUNCTION public.diesel_manage_updated_at(_tbl regclass) OWNER TO music_booking;

--
-- Name: diesel_set_updated_at(); Type: FUNCTION; Schema: public; Owner: music_booking
--

CREATE FUNCTION public.diesel_set_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF (
        NEW IS DISTINCT FROM OLD AND
        NEW.updated_at IS NOT DISTINCT FROM OLD.updated_at
    ) THEN
        NEW.updated_at := current_timestamp;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.diesel_set_updated_at() OWNER TO music_booking;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: __diesel_schema_migrations; Type: TABLE; Schema: public; Owner: music_booking
--

CREATE TABLE public.__diesel_schema_migrations (
    version character varying(50) NOT NULL,
    run_on timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.__diesel_schema_migrations OWNER TO music_booking;

--
-- Name: artists; Type: TABLE; Schema: public; Owner: music_booking
--

CREATE TABLE public.artists (
    id integer NOT NULL,
    profile_complete boolean DEFAULT false NOT NULL,
    thumbnail_file text,
    brief_description text,
    long_description text
);


ALTER TABLE public.artists OWNER TO music_booking;

--
-- Name: event_status; Type: TABLE; Schema: public; Owner: music_booking
--

CREATE TABLE public.event_status (
    id integer NOT NULL,
    name text NOT NULL
);


ALTER TABLE public.event_status OWNER TO music_booking;

--
-- Name: event_status_id_seq; Type: SEQUENCE; Schema: public; Owner: music_booking
--

CREATE SEQUENCE public.event_status_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.event_status_id_seq OWNER TO music_booking;

--
-- Name: event_status_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: music_booking
--

ALTER SEQUENCE public.event_status_id_seq OWNED BY public.event_status.id;


--
-- Name: events; Type: TABLE; Schema: public; Owner: music_booking
--

CREATE TABLE public.events (
    id integer NOT NULL,
    venue_id integer NOT NULL,
    status_id integer NOT NULL,
    artist_id integer,
    title text NOT NULL,
    date_time timestamp with time zone NOT NULL,
    duration numeric(4,1) DEFAULT 1.5 NOT NULL,
    budget numeric(8,2) DEFAULT 200.0 NOT NULL,
    more_info text DEFAULT ''::text NOT NULL
);


ALTER TABLE public.events OWNER TO music_booking;

--
-- Name: events_id_seq; Type: SEQUENCE; Schema: public; Owner: music_booking
--

CREATE SEQUENCE public.events_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.events_id_seq OWNER TO music_booking;

--
-- Name: events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: music_booking
--

ALTER SEQUENCE public.events_id_seq OWNED BY public.events.id;


--
-- Name: offers; Type: TABLE; Schema: public; Owner: music_booking
--

CREATE TABLE public.offers (
    id integer NOT NULL,
    artist_id integer NOT NULL,
    event_id integer NOT NULL,
    accepted boolean
);


ALTER TABLE public.offers OWNER TO music_booking;

--
-- Name: offers_id_seq; Type: SEQUENCE; Schema: public; Owner: music_booking
--

CREATE SEQUENCE public.offers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.offers_id_seq OWNER TO music_booking;

--
-- Name: offers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: music_booking
--

ALTER SEQUENCE public.offers_id_seq OWNED BY public.offers.id;


--
-- Name: roles; Type: TABLE; Schema: public; Owner: music_booking
--

CREATE TABLE public.roles (
    id integer NOT NULL,
    name text NOT NULL
);


ALTER TABLE public.roles OWNER TO music_booking;

--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: music_booking
--

CREATE SEQUENCE public.roles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.roles_id_seq OWNER TO music_booking;

--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: music_booking
--

ALTER SEQUENCE public.roles_id_seq OWNED BY public.roles.id;


--
-- Name: uploads; Type: TABLE; Schema: public; Owner: music_booking
--

CREATE TABLE public.uploads (
    id integer NOT NULL,
    uploaded_by integer NOT NULL,
    filename text NOT NULL
);


ALTER TABLE public.uploads OWNER TO music_booking;

--
-- Name: uploads_id_seq; Type: SEQUENCE; Schema: public; Owner: music_booking
--

CREATE SEQUENCE public.uploads_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.uploads_id_seq OWNER TO music_booking;

--
-- Name: uploads_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: music_booking
--

ALTER SEQUENCE public.uploads_id_seq OWNED BY public.uploads.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: music_booking
--

CREATE TABLE public.users (
    id integer NOT NULL,
    role_id integer NOT NULL,
    username text NOT NULL,
    name text NOT NULL,
    password text NOT NULL,
    password_needs_changing boolean DEFAULT false NOT NULL,
    password_needs_rehash boolean DEFAULT false NOT NULL,
    session_token text DEFAULT ''::text NOT NULL,
    email text NOT NULL,
    phone text NOT NULL
);


ALTER TABLE public.users OWNER TO music_booking;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: music_booking
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_id_seq OWNER TO music_booking;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: music_booking
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: venues; Type: TABLE; Schema: public; Owner: music_booking
--

CREATE TABLE public.venues (
    id integer NOT NULL,
    profile_complete boolean DEFAULT false NOT NULL,
    thumbnail_file text,
    default_budget numeric(8,2) DEFAULT 200.0 NOT NULL
);


ALTER TABLE public.venues OWNER TO music_booking;

--
-- Name: event_status id; Type: DEFAULT; Schema: public; Owner: music_booking
--

ALTER TABLE ONLY public.event_status ALTER COLUMN id SET DEFAULT nextval('public.event_status_id_seq'::regclass);


--
-- Name: events id; Type: DEFAULT; Schema: public; Owner: music_booking
--

ALTER TABLE ONLY public.events ALTER COLUMN id SET DEFAULT nextval('public.events_id_seq'::regclass);


--
-- Name: offers id; Type: DEFAULT; Schema: public; Owner: music_booking
--

ALTER TABLE ONLY public.offers ALTER COLUMN id SET DEFAULT nextval('public.offers_id_seq'::regclass);


--
-- Name: roles id; Type: DEFAULT; Schema: public; Owner: music_booking
--

ALTER TABLE ONLY public.roles ALTER COLUMN id SET DEFAULT nextval('public.roles_id_seq'::regclass);


--
-- Name: uploads id; Type: DEFAULT; Schema: public; Owner: music_booking
--

ALTER TABLE ONLY public.uploads ALTER COLUMN id SET DEFAULT nextval('public.uploads_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: music_booking
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: __diesel_schema_migrations; Type: TABLE DATA; Schema: public; Owner: music_booking
--

COPY public.__diesel_schema_migrations (version, run_on) FROM stdin;
00000000000000	2019-07-07 17:08:06.135504
20190423212922	2019-07-07 17:08:06.153398
20190423215726	2019-07-07 17:08:06.177249
20190423215842	2019-07-07 17:08:06.181694
20190427160609	2019-07-07 17:08:06.191
20190503205443	2019-07-07 17:08:06.197792
20190503210031	2019-07-07 17:08:06.205289
20190510113528	2019-07-07 17:08:06.210341
20190519204325	2019-07-07 17:08:06.216569
20190707131714	2019-07-07 17:08:06.223126
\.


--
-- Data for Name: artists; Type: TABLE DATA; Schema: public; Owner: music_booking
--

COPY public.artists (id, profile_complete, thumbnail_file, brief_description, long_description) FROM stdin;
6	f	2a64b4ce-8416-4abc-9210-db8ab48b02f2.png	Cover artist	Laura is an upbeat cover artist from Swansea who covers a wide range of popular music including a variety of genres. She takes requests and can play with her stomp box to get people up and dancing, as well as being able to play chilled-out acoustic songs for a more relaxed atmosphere.
7	f	4300a6b1-7a3d-46ed-8a54-2657ec704a52.png	Four-piece originals band	An exciting and entertaining four-piece band from South Wales, we have an extensive back catalogue which will guarantee to get you up and dancing. Fonz and the Poet are designed to bring the life to the party, be it a wedding, party, occasion, or just a plain old Sunday night in a club!
8	f	5043f313-e22a-4cee-811f-80bd223a740a.png	Cover artist	Jeris is a solo cover artist from Swansea, who has extensive experience with weddings, parties and corporate functions as well as smaller local venues. With her ability to offer solo, duo, band and extended band packages, Jeris will be sure to cater to your every need for your venue or event!
\.


--
-- Data for Name: event_status; Type: TABLE DATA; Schema: public; Owner: music_booking
--

COPY public.event_status (id, name) FROM stdin;
1	Unconfirmed
2	Confirmed
3	Cancelled
\.


--
-- Data for Name: events; Type: TABLE DATA; Schema: public; Owner: music_booking
--

COPY public.events (id, venue_id, status_id, artist_id, title, date_time, duration, budget, more_info) FROM stdin;
1	3	1	\N	Country	2019-07-08 18:00:00+00	1.5	200.00	
2	3	2	6	18:00	2019-07-09 17:00:00+00	1.5	200.00	
4	3	1	\N	Band	2019-07-10 18:00:00+00	1.5	200.00	
5	4	1	\N	Ragan's rocking evening	2019-07-09 16:00:00+00	1.5	200.00	
3	3	3	6	19:00	2019-07-09 18:00:00+00	1.5	200.00	
\.


--
-- Data for Name: offers; Type: TABLE DATA; Schema: public; Owner: music_booking
--

COPY public.offers (id, artist_id, event_id, accepted) FROM stdin;
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: music_booking
--

COPY public.roles (id, name) FROM stdin;
1	Admin
2	Approver
3	Venue
4	Artist
\.


--
-- Data for Name: uploads; Type: TABLE DATA; Schema: public; Owner: music_booking
--

COPY public.uploads (id, uploaded_by, filename) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: music_booking
--

COPY public.users (id, role_id, username, name, password, password_needs_changing, password_needs_rehash, session_token, email, phone) FROM stdin;
3	3	crown	The Crown	JGFyZ29uMmlkJHY9MTkkbT02NTUzNix0PTIscD0xJFFXL3B4Q1AwVTRRL05EdUUvUk5uckEkL3dzNkMwdDVwV0dFRWowRTBIdUdQdWdhRDFQanBUZE9ZT2svaG9NNHRGMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=	f	f		the@crown.x	+(44)666
4	3	scepter	And Sceptre	JGFyZ29uMmlkJHY9MTkkbT02NTUzNix0PTIscD0xJFFXL3B4Q1AwVTRRL05EdUUvUk5uckEkL3dzNkMwdDVwV0dFRWowRTBIdUdQdWdhRDFQanBUZE9ZT2svaG9NNHRGMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=	f	f		and@scepter.x	+(44)4573957893489
5	3	bush	Bush and Broccoli	JGFyZ29uMmlkJHY9MTkkbT02NTUzNix0PTIscD0xJFFXL3B4Q1AwVTRRL05EdUUvUk5uckEkL3dzNkMwdDVwV0dFRWowRTBIdUdQdWdhRDFQanBUZE9ZT2svaG9NNHRGMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=	f	f		bush@broccoli.x	+(44)0
6	4	laura	Laura Benjamin	JGFyZ29uMmlkJHY9MTkkbT02NTUzNix0PTIscD0xJFFXL3B4Q1AwVTRRL05EdUUvUk5uckEkL3dzNkMwdDVwV0dFRWowRTBIdUdQdWdhRDFQanBUZE9ZT2svaG9NNHRGMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=	f	f		laura.benj93@gmail.com	+(44)0000 000000
7	4	fonz	Fonz and the Poet	JGFyZ29uMmlkJHY9MTkkbT02NTUzNix0PTIscD0xJFFXL3B4Q1AwVTRRL05EdUUvUk5uckEkL3dzNkMwdDVwV0dFRWowRTBIdUdQdWdhRDFQanBUZE9ZT2svaG9NNHRGMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=	f	f		fonz@pitch.com	+(44)0000 000000
8	4	jeris	Jeris Spencer	JGFyZ29uMmlkJHY9MTkkbT02NTUzNix0PTIscD0xJFFXL3B4Q1AwVTRRL05EdUUvUk5uckEkL3dzNkMwdDVwV0dFRWowRTBIdUdQdWdhRDFQanBUZE9ZT2svaG9NNHRGMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=	f	f		@pitch.com	+(44)0000 000000
2	2	approver	Approver	JGFyZ29uMmlkJHY9MTkkbT02NTUzNix0PTIscD0xJEd3RXRKMStmSFhLVHNKMGRqekV2SGckRTZTMGhKZ2xlalNLZE42RVZQUkNHR2ozR2xTVjRsWEhvd2pRNkZBUDYrdwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=	f	f	412e1798-a692-48ca-a501-792327e41dde	approver@a.x	+(44) 32323232323232
9	3	Fredddddddy	Test123	JGFyZ29uMmlkJHY9MTkkbT02NTUzNix0PTIscD0xJEd3RXRKMStmSFhLVHNKMGRqekV2SGckRTZTMGhKZ2xlalNLZE42RVZQUkNHR2ozR2xTVjRsWEhvd2pRNkZBUDYrdwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=	f	f	2a3be975-d6ab-44f8-ab93-606bcfcfcd79	test123@dfdfjd.com	123
1	1	admin	Admin	JGFyZ29uMmlkJHY9MTkkbT02NTUzNix0PTIscD0xJFFXL3B4Q1AwVTRRL05EdUUvUk5uckEkL3dzNkMwdDVwV0dFRWowRTBIdUdQdWdhRDFQanBUZE9ZT2svaG9NNHRGMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=	f	f	052045cc-7681-4d11-bb33-7be82f90682e	admin@admin.x	+(44)123 3232 3233
\.


--
-- Data for Name: venues; Type: TABLE DATA; Schema: public; Owner: music_booking
--

COPY public.venues (id, profile_complete, thumbnail_file, default_budget) FROM stdin;
3	f	e4bf9649-8ba4-4b42-bd7a-6e6e38eb4bab.png	201.00
4	f	2058c7a2-ef89-41b9-a90f-14c17b7241df.jpg	1999.30
5	f	\N	10.00
9	f	\N	200.00
\.


--
-- Name: event_status_id_seq; Type: SEQUENCE SET; Schema: public; Owner: music_booking
--

SELECT pg_catalog.setval('public.event_status_id_seq', 3, true);


--
-- Name: events_id_seq; Type: SEQUENCE SET; Schema: public; Owner: music_booking
--

SELECT pg_catalog.setval('public.events_id_seq', 5, true);


--
-- Name: offers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: music_booking
--

SELECT pg_catalog.setval('public.offers_id_seq', 1, false);


--
-- Name: roles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: music_booking
--

SELECT pg_catalog.setval('public.roles_id_seq', 4, true);


--
-- Name: uploads_id_seq; Type: SEQUENCE SET; Schema: public; Owner: music_booking
--

SELECT pg_catalog.setval('public.uploads_id_seq', 1, false);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: music_booking
--

SELECT pg_catalog.setval('public.users_id_seq', 9, true);


--
-- Name: __diesel_schema_migrations __diesel_schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: music_booking
--

ALTER TABLE ONLY public.__diesel_schema_migrations
    ADD CONSTRAINT __diesel_schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: artists artists_pkey; Type: CONSTRAINT; Schema: public; Owner: music_booking
--

ALTER TABLE ONLY public.artists
    ADD CONSTRAINT artists_pkey PRIMARY KEY (id);


--
-- Name: event_status event_status_pkey; Type: CONSTRAINT; Schema: public; Owner: music_booking
--

ALTER TABLE ONLY public.event_status
    ADD CONSTRAINT event_status_pkey PRIMARY KEY (id);


--
-- Name: events events_pkey; Type: CONSTRAINT; Schema: public; Owner: music_booking
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: offers offers_pkey; Type: CONSTRAINT; Schema: public; Owner: music_booking
--

ALTER TABLE ONLY public.offers
    ADD CONSTRAINT offers_pkey PRIMARY KEY (id);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: music_booking
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: uploads uploads_pkey; Type: CONSTRAINT; Schema: public; Owner: music_booking
--

ALTER TABLE ONLY public.uploads
    ADD CONSTRAINT uploads_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: music_booking
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: music_booking
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: venues venues_pkey; Type: CONSTRAINT; Schema: public; Owner: music_booking
--

ALTER TABLE ONLY public.venues
    ADD CONSTRAINT venues_pkey PRIMARY KEY (id);


--
-- Name: artists artists_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: music_booking
--

ALTER TABLE ONLY public.artists
    ADD CONSTRAINT artists_id_fkey FOREIGN KEY (id) REFERENCES public.users(id);


--
-- Name: events events_artist_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: music_booking
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_artist_id_fkey FOREIGN KEY (artist_id) REFERENCES public.users(id);


--
-- Name: events events_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: music_booking
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_status_id_fkey FOREIGN KEY (status_id) REFERENCES public.event_status(id);


--
-- Name: events events_venue_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: music_booking
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_venue_id_fkey FOREIGN KEY (venue_id) REFERENCES public.users(id);


--
-- Name: offers offers_artist_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: music_booking
--

ALTER TABLE ONLY public.offers
    ADD CONSTRAINT offers_artist_id_fkey FOREIGN KEY (artist_id) REFERENCES public.artists(id);


--
-- Name: offers offers_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: music_booking
--

ALTER TABLE ONLY public.offers
    ADD CONSTRAINT offers_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.events(id);


--
-- Name: uploads uploads_uploaded_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: music_booking
--

ALTER TABLE ONLY public.uploads
    ADD CONSTRAINT uploads_uploaded_by_fkey FOREIGN KEY (uploaded_by) REFERENCES public.users(id);


--
-- Name: users users_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: music_booking
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id);


--
-- Name: venues venues_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: music_booking
--

ALTER TABLE ONLY public.venues
    ADD CONSTRAINT venues_id_fkey FOREIGN KEY (id) REFERENCES public.users(id);


--
-- PostgreSQL database dump complete
--

