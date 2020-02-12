DO $do$
DECLARE
    sch text;
BEGIN
    FOR sch IN SELECT nspname FROM pg_namespace
    LOOP
        EXECUTE format($$ GRANT USAGE ON SCHEMA %I TO ${db_ro_only_role} $$, sch);
        EXECUTE format($$ GRANT SELECT ON ALL TABLES IN SCHEMA %I TO ${db_ro_only_role} $$, sch);
        EXECUTE format($$ GRANT USAGE ON SCHEMA %I TO ${db_rw_only_role} $$, sch);
        EXECUTE format($$ GRANT SELECT,UPDATE,DELETE,INSERT ON ALL TABLES IN SCHEMA %I TO ${db_rw_only_role} $$, sch);
    END LOOP;
END;
$do$;
