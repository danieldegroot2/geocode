#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

readonly START_DIR=$PWD
readonly SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")

function exec_psql_file() {
	if [[ -n ${POSTGRES_HOST:-} ]]; then
		PGPASSWORD=$POSTGRES_PASSWORD psql -v ON_ERROR_STOP=1 --host="$POSTGRES_HOST" --port="$POSTGRES_PORT" --dbname="$POSTGRES_DB" --username="$POSTGRES_USER" -f $1
	else
		PGPASSWORD=$POSTGRES_PASSWORD psql -v ON_ERROR_STOP=1 --dbname="$POSTGRES_DB" --username="$POSTGRES_USER" -f $1
	fi
}

function exec_pgsql2shp() {
	outfile=$1
	shift
	if [[ -n ${POSTGRES_HOST:-} ]]; then
		pgsql2shp -f $outfile -h $POSTGRES_HOST -p $POSTGRES_PORT -u $POSTGRES_USER -P "$POSTGRES_PASSWORD" $POSTGRES_DB "$@"
	else
		PGPASSWORD=$POSTGRES_PASSWORD psql -v ON_ERROR_STOP=1 --dbname="$POSTGRES_DB" --username="$POSTGRES_USER"
	fi
}

function export_centroids() {
	echo "Exporting Centroids to shapefile"
	exec_pgsql2shp layers/centroids "SELECT id, isoCountryCode2Digit AS name, isoCountryCode2Digit, ST_Expand(geom, 0.00001) FROM centroids"

	echo "Centroids shapefile export complete"
	echo
}

function export_natural_earth() {
	echo "Exporting Natural Earth to shapefile"
	exec_pgsql2shp layers/political_subdivided "SELECT iso_a2 AS id, name AS name, iso_a2 AS isoCountryCode2Digit, geom FROM political_subdivided"

	echo "Natural Earth shapefile export complete"
	echo
}

function export_marine_regions() {
	echo "Exporting Marine Regions to shapefile"
	exec_pgsql2shp layers/eez_subdivided "SELECT mrgid AS id, geoname AS name, CONCAT_WS(' ', im1.iso2, im2.iso2, im3.iso2) AS isoCountryCode2Digit, geom FROM eez_subdivided eez LEFT OUTER JOIN iso_map im1 ON eez.iso_ter1 = im1.iso3 LEFT OUTER JOIN iso_map im2 ON eez.iso_ter2 = im2.iso3 LEFT OUTER JOIN iso_map im3 ON eez.iso_ter3 = im3.iso3"

	echo "Marine Regions shapefile export complete"
	echo
}

function export_marine_regions_union() {
	echo "Exporting Marine Regions Land Union to shapefile"
	exec_pgsql2shp layers/political_eez_subdivided "SELECT mrgid_eez AS id, \"union\" AS name, CONCAT_WS(' ', im1.iso2, im2.iso2, im3.iso2) AS isoCountryCode2Digit, geom FROM political_eez_subdivided eez LEFT OUTER JOIN iso_map im1 ON eez.iso_ter1 = im1.iso3 LEFT OUTER JOIN iso_map im2 ON eez.iso_ter2 = im2.iso3 LEFT OUTER JOIN iso_map im3 ON eez.iso_ter3 = im3.iso3"

	echo "Marine Regions Land Union shapefile export complete"
	echo
}

function export_gadm() {
	echo "Exporting GADM to shapefile"
	exec_pgsql2shp layers/gadm_subdivided "SELECT gid_0, gid_1, gid_2, gid_3, name_0, name_1, name_2, name_3, iso_map.iso2 AS isoCountryCode2Digit, geom FROM gadm3_subdivided LEFT OUTER JOIN iso_map ON gadm3_subdivided.gid_0 = iso_map.iso3"

	echo "GADM shapefile export complete"
	echo
}

function export_iho() {
	echo "Exporting IHO to shapefile"
	exec_pgsql2shp layers/iho_subdivided "SELECT 'http://marineregions.org/mrgid/' || mrgid AS id, name, NULL AS isoCountryCode2Digit, geom FROM iho_subdivided"

	echo "IHO shapefile export complete"
	echo
}

function export_wgsrpd() {
	echo "Exporting WGSRPD to shapefile"
	exec_pgsql2shp layers/wgsrpd_subdivided "SELECT 'WGSRPD:' || level4_cod AS id, level_4_na AS name, iso_code AS isoCountryCode2Digit, geom FROM wgsrpd_level4_subdivided"

	echo "WGSRPD shapefile export complete"
	echo
}

function export_continents() {
	echo "Exporting Continents to shapefile"
	exec_pgsql2shp layers/continents_subdivided "SELECT continent AS id, continent AS name, NULL AS isoCountryCode2Digit, geom FROM continent_subdivided"

	echo "Continents shapefile export complete"
	echo
}

function subdivide_layers() {
	echo "Subdividing layers"
	cd $START_DIR
	exec_psql_file $SCRIPT_DIR/subdivide_layers.sql

	echo "Subdividing layers complete"
	echo
}

if [[ -e export-complete ]]; then
	echo "Data already exported"
else
	echo "Exporting data"
	subdivide_layers
	mkdir -p layers
	export_centroids
	export_natural_earth
	export_marine_regions
	export_marine_regions_union
	export_gadm
	export_iho
	export_wgsrpd
	export_continents
	touch export-complete
fi
