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
-- Name: covvee; Type: DATABASE; Schema: -; Owner: covvee
--

CREATE DATABASE covvee WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'en_US.UTF-8' LC_CTYPE = 'en_US.UTF-8';


ALTER DATABASE covvee OWNER TO covvee;

\connect covvee

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

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: products; Type: TABLE; Schema: public; Owner: covvee
--

CREATE TABLE public.products (
    id bigint NOT NULL,
    title character varying(250) NOT NULL,
    description text NOT NULL,
    shortname character varying(50) NOT NULL,
    priceinpence bigint NOT NULL
);


ALTER TABLE public.products OWNER TO covvee;

--
-- Name: products_id_seq; Type: SEQUENCE; Schema: public; Owner: covvee
--

CREATE SEQUENCE public.products_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.products_id_seq OWNER TO covvee;

--
-- Name: products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: covvee
--

ALTER SEQUENCE public.products_id_seq OWNED BY public.products.id;


--
-- Name: purchaseextradata; Type: TABLE; Schema: public; Owner: covvee
--

CREATE TABLE public.purchaseextradata (
    id bigint NOT NULL,
    purchaseid bigint,
    dataname character varying(50) NOT NULL,
    datavalue text NOT NULL
);


ALTER TABLE public.purchaseextradata OWNER TO covvee;

--
-- Name: purchaseextradata_id_seq; Type: SEQUENCE; Schema: public; Owner: covvee
--

CREATE SEQUENCE public.purchaseextradata_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.purchaseextradata_id_seq OWNER TO covvee;

--
-- Name: purchaseextradata_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: covvee
--

ALTER SEQUENCE public.purchaseextradata_id_seq OWNED BY public.purchaseextradata.id;


--
-- Name: purchases; Type: TABLE; Schema: public; Owner: covvee
--

CREATE TABLE public.purchases (
    id bigint NOT NULL,
    priceinpence bigint NOT NULL,
    userid bigint,
    ordertime timestamp with time zone NOT NULL,
    stripecustomerid character varying(50) NOT NULL,
    stripepaymentid character varying(50) NOT NULL,
    email character varying(250) NOT NULL,
    deliverypostcode character varying(250) NOT NULL,
    deliveryname character varying(250) NOT NULL,
    deliveryaddressline1 character varying(250) NOT NULL,
    deliveryaddressline2 character varying(250) NOT NULL,
    deliverycity character varying(250) NOT NULL,
    deliverycountry character varying(250) NOT NULL,
    billingpostcode character varying(250) NOT NULL,
    billingname character varying(250) NOT NULL,
    billingaddressline1 character varying(250) NOT NULL,
    billingaddressline2 character varying(250) NOT NULL,
    billingcity character varying(250) NOT NULL,
    billingcountry character varying(250) NOT NULL
);


ALTER TABLE public.purchases OWNER TO covvee;

--
-- Name: purchases_id_seq; Type: SEQUENCE; Schema: public; Owner: covvee
--

CREATE SEQUENCE public.purchases_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.purchases_id_seq OWNER TO covvee;

--
-- Name: purchases_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: covvee
--

ALTER SEQUENCE public.purchases_id_seq OWNED BY public.purchases.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: covvee
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    username character varying(50) NOT NULL,
    email character varying(250) NOT NULL,
    firstname character varying(50),
    secondname character varying(50),
    providerid character varying(50) NOT NULL,
    provider character varying(50) NOT NULL,
    accesstoken character varying(250) NOT NULL,
    lastaccess timestamp with time zone NOT NULL,
    stripecustomerid character varying(50) NOT NULL
);


ALTER TABLE public.users OWNER TO covvee;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: covvee
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_id_seq OWNER TO covvee;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: covvee
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: products id; Type: DEFAULT; Schema: public; Owner: covvee
--

ALTER TABLE ONLY public.products ALTER COLUMN id SET DEFAULT nextval('public.products_id_seq'::regclass);


--
-- Name: purchaseextradata id; Type: DEFAULT; Schema: public; Owner: covvee
--

ALTER TABLE ONLY public.purchaseextradata ALTER COLUMN id SET DEFAULT nextval('public.purchaseextradata_id_seq'::regclass);


--
-- Name: purchases id; Type: DEFAULT; Schema: public; Owner: covvee
--

ALTER TABLE ONLY public.purchases ALTER COLUMN id SET DEFAULT nextval('public.purchases_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: covvee
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: covvee
--

COPY public.products (id, title, description, shortname, priceinpence) FROM stdin;
1	AeroPro Filter for aeropress	The filter	AeroPro	1299
\.


--
-- Data for Name: purchaseextradata; Type: TABLE DATA; Schema: public; Owner: covvee
--

COPY public.purchaseextradata (id, purchaseid, dataname, datavalue) FROM stdin;
\.


--
-- Data for Name: purchases; Type: TABLE DATA; Schema: public; Owner: covvee
--

COPY public.purchases (id, priceinpence, userid, ordertime, stripecustomerid, stripepaymentid, email, deliverypostcode, deliveryname, deliveryaddressline1, deliveryaddressline2, deliverycity, deliverycountry, billingpostcode, billingname, billingaddressline1, billingaddressline2, billingcity, billingcountry) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: covvee
--

COPY public.users (id, username, email, firstname, secondname, providerid, provider, accesstoken, lastaccess, stripecustomerid) FROM stdin;
1		cs2dsb@gmail.com			101058968362808597691	gplus	ya29.Gl0HB24JMye-u-hYx9t5vPMTZTxBq4_CvWDC_IdIoGTKK4LHT8GvSHCyhOFG3GSxgobkUUhZFS8AZ6Pn3fKAHM9ZQg3bQ1RZDhmexZfzswvtfqkawBjCnWh-y7fpDM4	2019-05-12 15:22:21.087684+00	
2	Noah Alddafgfjidij Rosenthalsky	mbzugnhvob_1575470135@tfbnw.net			110354687113451	facebook	EAAZADguwp1GIBACdUzKDNqibuYVVvVO6EAjYXPHEf0No07dzHZCeDm7NGF1w6EwE13ZBb6O1sDcvHwrVH0J3FmjECCxCzzg7TsHZBCtZAZCc4r040bpbCbxqhW6pebw5Xw1B0REJNe1GnSvoEe3oP3IeuZCRiYjnUGMzyIPU780wqQbjcmUU5LZCNvK3cGwaIU0ZD	2019-12-04 14:45:17.800905+00	
3	cs2dsb				397554621	twitter	397554621-PQKzVQVlUNgpBPfO4EFoq0T3eraVHk6DHfduCfqx	2019-12-04 14:45:42.978216+00	
4	Thomas Shelby	geogatedproject252@gmail.com			1001949978289	facebook	EAAZADguwp1GIBAPFeRubm7CtRT6klqj0ojU8930ybRpxevg7Vbqt534NnnGogcu3cIqjDfcxhFuhKMVOu8dwIxQv5fqKuGO6tlVHLMuWOMcUNs3SHGw7p01Dng9reFDF7rb9GtoOzPEW2oljBcx7gfYuymFbGH81C9q8ND7fpdCaA3WB8	2020-02-06 03:01:43.349715+00	
5		mnirun@gmail.com			117401214111275915867	gplus	ya29.a0Ae4lvC0ra2bXLnfwrkgMh1UzXCqMPtMuwcsIwH-KoAL6u7dGRQVGHMAWUmTtnP_NC01sNNWwM4M-iwJ2fUzQMXLpRJO5kW2TeZrp0I8UyBfxUdzCHgb3wbElaCWtra1MtN-33jXFdyeHTD3-s027k7cW2R8PmdS-5Fg	2020-04-11 09:05:37.373415+00	
\.


--
-- Name: products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: covvee
--

SELECT pg_catalog.setval('public.products_id_seq', 1, true);


--
-- Name: purchaseextradata_id_seq; Type: SEQUENCE SET; Schema: public; Owner: covvee
--

SELECT pg_catalog.setval('public.purchaseextradata_id_seq', 1, false);


--
-- Name: purchases_id_seq; Type: SEQUENCE SET; Schema: public; Owner: covvee
--

SELECT pg_catalog.setval('public.purchases_id_seq', 1, false);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: covvee
--

SELECT pg_catalog.setval('public.users_id_seq', 5, true);


--
-- Name: products product_primary_key; Type: CONSTRAINT; Schema: public; Owner: covvee
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT product_primary_key PRIMARY KEY (id);


--
-- Name: products products_shortname_key; Type: CONSTRAINT; Schema: public; Owner: covvee
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_shortname_key UNIQUE (shortname);


--
-- Name: purchases purchase_primary_key; Type: CONSTRAINT; Schema: public; Owner: covvee
--

ALTER TABLE ONLY public.purchases
    ADD CONSTRAINT purchase_primary_key PRIMARY KEY (id);


--
-- Name: purchaseextradata purchaseed_primary_key; Type: CONSTRAINT; Schema: public; Owner: covvee
--

ALTER TABLE ONLY public.purchaseextradata
    ADD CONSTRAINT purchaseed_primary_key PRIMARY KEY (id);


--
-- Name: users user_primary_key; Type: CONSTRAINT; Schema: public; Owner: covvee
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT user_primary_key PRIMARY KEY (id);


--
-- Name: purchaseextradata purchaseextradata_purchaseid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: covvee
--

ALTER TABLE ONLY public.purchaseextradata
    ADD CONSTRAINT purchaseextradata_purchaseid_fkey FOREIGN KEY (purchaseid) REFERENCES public.purchases(id);


--
-- Name: purchases purchases_userid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: covvee
--

ALTER TABLE ONLY public.purchases
    ADD CONSTRAINT purchases_userid_fkey FOREIGN KEY (userid) REFERENCES public.users(id);


--
-- PostgreSQL database dump complete
--

