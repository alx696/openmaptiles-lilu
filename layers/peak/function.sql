-- 通过视图过滤掉无用数据
CREATE OR REPLACE VIEW lilu_peak_point AS
(
    SELECT pp.osm_id,
           pp.name,
           substring(pp.ele FROM E'^(-?\\d+)(\\D|$)')::int AS ele,
           pp.geometry
    FROM osm_peak_point pp, ne_10m_admin_0_countries ne
    WHERE ST_Intersects(pp.geometry, ne.geometry)
        AND pp.name != ''
        AND pp.ele IS NOT NULL
        AND pp.ele != ''
        AND pp.ele ~ '^([0-9]+[.]?[0-9]*|[.][0-9]+)$'
);

-- 创建函数
CREATE OR REPLACE FUNCTION lilu_layer_peak(bbox geometry, zoom_level int, pixel_width numeric)
RETURNS TABLE (
    osm_id          bigint,
    name            text,
    ele             int,
    geometry        geometry
) AS
$$

-- 缩放5显示海拔7千米以上
SELECT osm_id,
    name,
    ele,
    geometry
FROM lilu_peak_point
WHERE zoom_level = 5
    AND geometry && bbox
    AND ele >= 7000

UNION ALL

-- 缩放6显示海拔6千米以上
SELECT osm_id,
    name,
    ele,
    geometry
FROM lilu_peak_point
WHERE zoom_level = 6
    AND geometry && bbox
    AND ele >= 6000

UNION ALL

-- 缩放7显示海拔5千米以上
SELECT osm_id,
    name,
    ele,
    geometry
FROM lilu_peak_point
WHERE zoom_level = 7
    AND geometry && bbox
    AND ele >= 5000

UNION ALL

-- 缩放8显示海拔4千米以上
SELECT osm_id,
    name,
    ele,
    geometry
FROM lilu_peak_point
WHERE zoom_level = 8
    AND geometry && bbox
    AND ele >= 4000

UNION ALL

-- 缩放9显示海拔3千米以上
SELECT osm_id,
    name,
    ele,
    geometry
FROM lilu_peak_point
WHERE zoom_level = 9
    AND geometry && bbox
    AND ele >= 3000

UNION ALL

-- 缩放9显示海拔3千米以上
SELECT osm_id,
    name,
    ele,
    geometry
FROM lilu_peak_point
WHERE zoom_level >= 10
    AND geometry && bbox

ORDER BY ele DESC;

$$ LANGUAGE SQL STABLE
-- STRICT
PARALLEL SAFE ;
