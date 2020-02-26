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
-- Name: hstore; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA public;


--
-- Name: EXTENSION hstore; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION hstore IS 'data type for storing sets of (key, value) pairs';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.events (
    id bigint NOT NULL,
    title character varying NOT NULL,
    start_time timestamp without time zone NOT NULL,
    end_time timestamp without time zone NOT NULL,
    user_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.events_id_seq OWNED BY public.events.id;


--
-- Name: google_calendar_configs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.google_calendar_configs (
    id bigint NOT NULL,
    "authorization" public.hstore,
    user_id bigint NOT NULL
);


--
-- Name: google_calendar_configs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.google_calendar_configs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: google_calendar_configs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.google_calendar_configs_id_seq OWNED BY public.google_calendar_configs.id;


--
-- Name: google_calendars; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.google_calendars (
    user_id bigint NOT NULL,
    name character varying,
    description character varying,
    id bigint NOT NULL,
    remote_id character varying
);


--
-- Name: google_calendars_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.google_calendars_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: google_calendars_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.google_calendars_id_seq OWNED BY public.google_calendars.id;


--
-- Name: google_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.google_events (
    id bigint NOT NULL,
    remote_id character varying,
    event_id bigint NOT NULL,
    google_calendar_id bigint NOT NULL
);


--
-- Name: google_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.google_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: google_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.google_events_id_seq OWNED BY public.google_events.id;


--
-- Name: outbound_event_configs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.outbound_event_configs (
    id bigint NOT NULL,
    owner_id bigint NOT NULL,
    google_calendar_id bigint NOT NULL,
    receiver_id bigint NOT NULL
);


--
-- Name: outbound_event_configs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.outbound_event_configs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: outbound_event_configs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.outbound_event_configs_id_seq OWNED BY public.outbound_event_configs.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events ALTER COLUMN id SET DEFAULT nextval('public.events_id_seq'::regclass);


--
-- Name: google_calendar_configs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.google_calendar_configs ALTER COLUMN id SET DEFAULT nextval('public.google_calendar_configs_id_seq'::regclass);


--
-- Name: google_calendars id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.google_calendars ALTER COLUMN id SET DEFAULT nextval('public.google_calendars_id_seq'::regclass);


--
-- Name: google_events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.google_events ALTER COLUMN id SET DEFAULT nextval('public.google_events_id_seq'::regclass);


--
-- Name: outbound_event_configs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outbound_event_configs ALTER COLUMN id SET DEFAULT nextval('public.outbound_event_configs_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: events events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: google_calendar_configs google_calendar_configs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.google_calendar_configs
    ADD CONSTRAINT google_calendar_configs_pkey PRIMARY KEY (id);


--
-- Name: google_calendars google_calendars_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.google_calendars
    ADD CONSTRAINT google_calendars_pkey PRIMARY KEY (id);


--
-- Name: google_events google_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.google_events
    ADD CONSTRAINT google_events_pkey PRIMARY KEY (id);


--
-- Name: outbound_event_configs outbound_event_configs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outbound_event_configs
    ADD CONSTRAINT outbound_event_configs_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_events_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_events_on_user_id ON public.events USING btree (user_id);


--
-- Name: index_google_calendar_configs_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_google_calendar_configs_on_user_id ON public.google_calendar_configs USING btree (user_id);


--
-- Name: index_google_calendars_on_lowercase_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_google_calendars_on_lowercase_name ON public.google_calendars USING btree (lower((name)::text));


--
-- Name: index_google_calendars_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_google_calendars_on_user_id ON public.google_calendars USING btree (user_id);


--
-- Name: index_google_events_on_event_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_google_events_on_event_id ON public.google_events USING btree (event_id);


--
-- Name: index_google_events_on_google_calendar_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_google_events_on_google_calendar_id ON public.google_events USING btree (google_calendar_id);


--
-- Name: index_outbound_event_configs_on_google_calendar_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_outbound_event_configs_on_google_calendar_id ON public.outbound_event_configs USING btree (google_calendar_id);


--
-- Name: index_outbound_event_configs_on_owner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_outbound_event_configs_on_owner_id ON public.outbound_event_configs USING btree (owner_id);


--
-- Name: index_outbound_event_configs_on_receiver_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_outbound_event_configs_on_receiver_id ON public.outbound_event_configs USING btree (receiver_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON public.users USING btree (reset_password_token);


--
-- Name: events fk_rails_0cb5590091; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT fk_rails_0cb5590091 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: google_calendars fk_rails_147a5d7923; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.google_calendars
    ADD CONSTRAINT fk_rails_147a5d7923 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: google_calendar_configs fk_rails_1d6378e93e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.google_calendar_configs
    ADD CONSTRAINT fk_rails_1d6378e93e FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: google_events fk_rails_4517a58f37; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.google_events
    ADD CONSTRAINT fk_rails_4517a58f37 FOREIGN KEY (google_calendar_id) REFERENCES public.google_calendars(id);


--
-- Name: outbound_event_configs fk_rails_d2339ab5f3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outbound_event_configs
    ADD CONSTRAINT fk_rails_d2339ab5f3 FOREIGN KEY (google_calendar_id) REFERENCES public.google_calendars(id);


--
-- Name: google_events fk_rails_e409445852; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.google_events
    ADD CONSTRAINT fk_rails_e409445852 FOREIGN KEY (event_id) REFERENCES public.events(id);


--
-- Name: outbound_event_configs fk_rails_e525e204fb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outbound_event_configs
    ADD CONSTRAINT fk_rails_e525e204fb FOREIGN KEY (receiver_id) REFERENCES public.users(id);


--
-- Name: outbound_event_configs fk_rails_f13b35dd05; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outbound_event_configs
    ADD CONSTRAINT fk_rails_f13b35dd05 FOREIGN KEY (owner_id) REFERENCES public.users(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20191020145032'),
('20191020152423'),
('20191020152619'),
('20191020154200'),
('20191021113505'),
('20191021121403'),
('20191021125032'),
('20191207003355'),
('20191208033813'),
('20191224232850'),
('20191225004211'),
('20191227090621'),
('20191227090849'),
('20191227092804'),
('20191230011550'),
('20200101050907'),
('20200123011434'),
('20200225125038');


