-- Political
DROP TABLE IF EXISTS political_subdivided;
CREATE TABLE political_subdivided AS
    SELECT iso_a2, name, geom
    FROM political
    WHERE ST_NPoints(geom) <= 1024;

INSERT INTO political_subdivided
    SELECT iso_a2, name, ST_Multi(ST_Subdivide(geom, 1024)) AS geom
    FROM political
    WHERE ST_NPoints(geom) > 1024 AND ST_NPoints(geom) <= 10000;

DO
$do$
DECLARE
   k   record;
BEGIN
   FOR k IN
      SELECT iso_a2, name FROM political WHERE ST_NPoints(geom) > 10000
   LOOP
      RAISE NOTICE 'Processing % (%)', k.iso_a2, k.name;
      INSERT INTO political_subdivided
        SELECT iso_a2, name, ST_Multi(ST_Subdivide(geom, 1024)) AS geom
        FROM political
        WHERE iso_a2 = k.iso_a2;
      RAISE NOTICE 'Completed % (%)', k.iso_a2, k.name;
   END LOOP;
END
$do$;

-- EEZ
DROP TABLE IF EXISTS eez_subdivided;
CREATE TABLE eez_subdivided AS
    SELECT *
    FROM eez
    WHERE ST_NPoints(geom) <= 1024;

INSERT INTO eez_subdivided
    SELECT gid, mrgid, geoname, mrgid_ter1, pol_type, mrgid_sov1, territory1, iso_ter1, sovereign1, mrgid_ter2, mrgid_sov2, territory2, iso_ter2,
        sovereign2, mrgid_ter3, mrgid_sov3, territory3, iso_ter3, sovereign3, x_1, y_1, mrgid_eez, area_km2, ST_Multi(ST_Subdivide(ST_MakeValid(geom), 1024)) AS geom
    FROM eez
    WHERE ST_NPoints(geom) > 1024 AND ST_NPoints(geom) <= 10000;

DO
$do$
DECLARE
   k   record;
BEGIN
   FOR k IN
      SELECT gid, geoname FROM eez WHERE ST_NPoints(geom) > 10000
   LOOP
      RAISE NOTICE 'Processing % (%)', k.gid, k.geoname;
      INSERT INTO eez_subdivided
        SELECT gid, mrgid, geoname, mrgid_ter1, pol_type, mrgid_sov1, territory1, iso_ter1, sovereign1, mrgid_ter2, mrgid_sov2, territory2, iso_ter2,
            sovereign2, mrgid_ter3, mrgid_sov3, territory3, iso_ter3, sovereign3, x_1, y_1, mrgid_eez, area_km2, ST_Multi(ST_Subdivide(ST_MakeValid(geom), 1024)) AS geom
        FROM eez
        WHERE gid = k.gid;
      RAISE NOTICE 'Completed % (%)', k.gid, k.geoname;
   END LOOP;
END
$do$;

-- GADM3
DROP TABLE IF EXISTS gadm3_subdivided;
CREATE TABLE gadm3_subdivided AS
    SELECT *
    FROM gadm3
    WHERE ST_NPoints(geom) <= 1024;

INSERT INTO gadm3_subdivided
    SELECT fid, uid, gid_0, id_0, name_0, gid_1, id_1, name_1, varname_1, nl_name_1, hasc_1, cc_1, type_1, engtype_1, validfr_1, validto_1,
           remarks_1, gid_2, id_2, name_2, varname_2, nl_name_2, hasc_2, cc_2, type_2, engtype_2, validfr_2, validto_2, remarks_2, gid_3, id_3, name_3,
           varname_3, nl_name_3, hasc_3, cc_3, type_3, engtype_3, validfr_3, validto_3, remarks_3, ST_Subdivide(geom, 1024) AS geom
      FROM gadm3
     WHERE ST_NPoints(geom) > 1024 AND ST_NPoints(geom) <= 10000;

DO
$do$
DECLARE
   k   record;
BEGIN
   FOR k IN
      SELECT fid FROM gadm3 WHERE ST_NPoints(geom) > 10000
   LOOP
      RAISE NOTICE 'Processing %', k.fid;
      INSERT INTO gadm3_subdivided
        SELECT fid, uid, gid_0, id_0, name_0, gid_1, id_1, name_1, varname_1, nl_name_1, hasc_1, cc_1, type_1, engtype_1, validfr_1, validto_1,
          remarks_1, gid_2, id_2, name_2, varname_2, nl_name_2, hasc_2, cc_2, type_2, engtype_2, validfr_2, validto_2, remarks_2, gid_3, id_3, name_3,
          varname_3, nl_name_3, hasc_3, cc_3, type_3, engtype_3, validfr_3, validto_3, remarks_3, ST_Subdivide(geom, 1024) AS geom
        FROM gadm3
        WHERE fid = k.fid;
      RAISE NOTICE 'Completed %', k.fid;
   END LOOP;
END
$do$;

-- IHO
DROP TABLE IF EXISTS iho_subdivided;
CREATE TABLE iho_subdivided AS
    SELECT *
    FROM iho
    WHERE ST_NPoints(geom) <= 1024;

INSERT INTO iho_subdivided
    SELECT gid, name, id, longitude, latitude, min_x, min_y, max_x, max_y, area, mrgid, ST_Multi(ST_Subdivide(ST_MakeValid(geom), 1024)) AS geom
    FROM iho
    WHERE ST_NPoints(geom) > 1024 AND ST_NPoints(geom) <= 10000;

DO
$do$
DECLARE
   k   record;
BEGIN
   FOR k IN
      SELECT gid, name FROM iho WHERE ST_NPoints(geom) > 10000
   LOOP
      RAISE NOTICE 'Processing % (%)', k.gid, k.name;
      INSERT INTO iho_subdivided
        SELECT gid, name, id, longitude, latitude, min_x, min_y, max_x, max_y, area, mrgid, ST_Multi(ST_Subdivide(ST_MakeValid(geom), 1024)) AS geom
        FROM iho
        WHERE gid = k.gid;
      RAISE NOTICE 'Completed % (%)', k.gid, k.name;
   END LOOP;
END
$do$;

-- WGSPRD
DROP TABLE IF EXISTS wgsrpd_level4_subdivided;
CREATE TABLE wgsrpd_level4_subdivided AS
    SELECT level4_cod, level_4_na, iso_code, geom
    FROM wgsrpd_level4
    WHERE ST_NPoints(geom) <= 1024;

INSERT INTO wgsrpd_level4_subdivided
    SELECT level4_cod, level_4_na, iso_code, ST_Multi(ST_Subdivide(geom, 1024)) AS geom
    FROM wgsrpd_level4
    WHERE ST_NPoints(geom) > 1024 AND ST_NPoints(geom) <= 10000;

DO
$do$
DECLARE
   k   record;
BEGIN
   FOR k IN
      SELECT gid, level4_cod FROM wgsrpd_level4 WHERE ST_NPoints(geom) > 10000
   LOOP
      RAISE NOTICE 'Processing % (%)', k.gid, k.level4_cod;
      INSERT INTO wgsrpd_level4_subdivided
        SELECT level4_cod, level_4_na, iso_code, ST_Multi(ST_Subdivide(geom, 1024)) AS geom
        FROM wgsrpd_level4
        WHERE gid = k.gid;
      RAISE NOTICE 'Completed % (%)', k.gid, k.level4_cod;
   END LOOP;
END
$do$;

-- Continent
DROP TABLE IF EXISTS continent_subdivided;
CREATE TABLE continent_subdivided AS
    SELECT continent, ST_Subdivide(geom, 1024) AS geom
    FROM continent
    WHERE gid_0 = 'AND';
TRUNCATE continent_subdivided;

DO
$do$
DECLARE
   k   record;
BEGIN
   FOR k IN
      SELECT continent FROM continent_union
   LOOP
      RAISE NOTICE 'Processing %', k.continent;
      INSERT INTO continent_subdivided
        SELECT continent, ST_Subdivide(geom, 1024) AS geom
        FROM continent_union
        WHERE continent = k.continent;
      RAISE NOTICE 'Completed %', k.continent;
   END LOOP;
END
$do$;
