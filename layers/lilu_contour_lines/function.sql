CREATE OR REPLACE FUNCTION layer_lilu_contour_lines(bbox GEOMETRY, zoom_level int)
RETURNS TABLE (elevation double precision, geometry GEOMETRY) AS
$$
SELECT elevation, geometry
FROM (
    SELECT elevation, geometry
    FROM lilu_contour_lines_500
    WHERE geometry && bbox
        AND zoom_level >= 10
) AS x
ORDER BY elevation ASC;
$$ LANGUAGE SQL STABLE
-- STRICT
PARALLEL SAFE ;
