-- Vistas 
USE PY1BD;
GO 

-- Vistas Completas Generales 

-- Vista de Todos los establecimientos 

CREATE OR ALTER VIEW vw_Establecimientos AS
SELECT 
    eh.ID_Establecimiento,
    eh.Nombre,
    eh.Cedula_Juridica,
    eh.Tipo,
    p.Nombre AS Provincia,
    c.Nombre AS Canton,
    d.Nombre AS Distrito,
    b.Nombre AS Barrio,
    dir.Senas_Exactas,
    dir.GPS,
    eh.Telefono1,
    eh.Telefono2,
    eh.Email,
    eh.Web_URL
FROM 
    Establecimiento_Hospedaje eh
    JOIN Direcciones dir ON eh.ID_Direccion = dir.ID_Direccion
    JOIN Barrios b ON dir.Codigo_Provincia = b.Codigo_Provincia 
                  AND dir.Codigo_Canton = b.Codigo_Canton 
                  AND dir.Codigo_Distrito = b.Codigo_Distrito 
                  AND dir.Codigo_Barrio = b.Codigo_Barrio
    JOIN Distritos d ON b.Codigo_Provincia = d.Codigo_Provincia 
                    AND b.Codigo_Canton = d.Codigo_Canton 
                    AND b.Codigo_Distrito = d.Codigo_Distrito
    JOIN Cantones c ON d.Codigo_Provincia = c.Codigo_Provincia 
                   AND d.Codigo_Canton = c.Codigo_Canton
    JOIN Provincias p ON c.Codigo_Provincia = p.Codigo_Provincia;

CREATE OR ALTER PROCEDURE sp_ObtenerEstablecimientos
AS
BEGIN

    SELECT * 
    FROM vw_Establecimientos;
END;
GO

exec sp_ObtenerEstablecimientos

select * from vw_Tipos_Habitacion
-- Vista de todas habitaciones
CREATE OR ALTER VIEW vw_Tipos_Habitacion AS
SELECT 
    ht.ID_Tipo_Habitacion,
    ht.ID_Establecimiento,
    eh.Nombre AS Nombre_Establecimiento,
    ht.Nombre AS Tipo_Habitacion,
    ht.Descripcion,
    ht.Tipo_Cama,
    ht.Precio,
    ht.Cantidad,
    (
        SELECT STRING_AGG(c.Nombre, ', ')
        FROM Habitacion_Comodidades hc
        JOIN Comodidades c ON hc.ID_Comodidad = c.ID_Comodidad
        WHERE hc.ID_Tipo_Habitacion = ht.ID_Tipo_Habitacion
    ) AS Comodidades
FROM 
    Habitacion_Tipo ht
    JOIN Establecimiento_Hospedaje eh ON ht.ID_Establecimiento = eh.ID_Establecimiento;

-- Vista de todos los clientes
select * from vw_Clientes
CREATE OR ALTER VIEW vw_Clientes AS
SELECT 
    c.ID_Cliente,
    c.Nombre,
    c.Apellido1,
    c.Apellido2,
    c.Fecha_Nacimiento,
    c.Cedula,
    c.Pais_Residencia,
    p.Nombre AS Provincia,
    ca.Nombre AS Canton,
    d.Nombre AS Distrito,
    dir.Senas_Exactas,
    c.Telefono1,
    c.Email
FROM 
    Clientes c
    LEFT JOIN Direcciones dir ON c.ID_Direccion = dir.ID_Direccion
    LEFT JOIN Provincias p ON dir.Codigo_Provincia = p.Codigo_Provincia
    LEFT JOIN Cantones ca ON dir.Codigo_Provincia = ca.Codigo_Provincia 
                         AND dir.Codigo_Canton = ca.Codigo_Canton
    LEFT JOIN Distritos d ON dir.Codigo_Provincia = d.Codigo_Provincia 
                          AND dir.Codigo_Canton = d.Codigo_Canton 
                          AND dir.Codigo_Distrito = d.Codigo_Distrito;

CREATE OR ALTER PROCEDURE sp_ObtenerClientes
AS
BEGIN

    SELECT * 
    FROM vw_Clientes;
END;
GO

-- Vista de Reservaciones
select * from vw_Reservaciones
CREATE OR ALTER VIEW vw_Reservaciones AS
SELECT 
    r.ID_Reservacion,
    r.Numero_Reserva,
    r.ID_Cliente,
    c.Nombre + ' ' + c.Apellido1 AS Nombre_Cliente,
    r.ID_Habitacion,
    h.Numero AS Numero_Habitacion,
    ht.Nombre AS Tipo_Habitacion,
    r.Fecha_Ingreso,
    r.Fecha_Salida,
    DATEDIFF(DAY, r.Fecha_Ingreso, r.Fecha_Salida) AS Noches,
    r.Cantidad_Personas,
    CASE WHEN r.Activa = 1 THEN 'Activa' ELSE 'Completada' END AS Estado,
    eh.Nombre AS Nombre_Establecimiento
FROM 
    Reservaciones r
    JOIN Clientes c ON r.ID_Cliente = c.ID_Cliente
    JOIN Habitaciones h ON r.ID_Habitacion = h.ID_Habitacion
    JOIN Habitacion_Tipo ht ON h.ID_Tipo_Habitacion = ht.ID_Tipo_Habitacion
    JOIN Establecimiento_Hospedaje eh ON ht.ID_Establecimiento = eh.ID_Establecimiento;

-- Vista completa de las Habitaciones
select * from vw_Habitaciones
CREATE OR ALTER VIEW vw_Habitaciones AS
SELECT 
    h.ID_Habitacion,
    h.Numero,
    h.Estado,
    h.ID_Tipo_Habitacion,
    ht.Nombre AS Tipo_Habitacion,
    ht.Precio AS Precio_Noche,
    eh.Nombre AS Nombre_Establecimiento,
    (
        SELECT STRING_AGG(c.Nombre, ', ')
        FROM Habitacion_Comodidades hc
        JOIN Comodidades c ON hc.ID_Comodidad = c.ID_Comodidad
        WHERE hc.ID_Tipo_Habitacion = ht.ID_Tipo_Habitacion
    ) AS Comodidades
FROM 
    Habitaciones h
    JOIN Habitacion_Tipo ht ON h.ID_Tipo_Habitacion = ht.ID_Tipo_Habitacion
    JOIN Establecimiento_Hospedaje eh ON ht.ID_Establecimiento = eh.ID_Establecimiento;


-- Vista completa de las facturas 
select * from vw_Facturas
CREATE OR ALTER VIEW vw_Facturas AS
SELECT 
    f.ID_Factura,
    f.Numero_Factura,
    f.Fecha_Factura,
    r.Numero_Reserva,
    c.Nombre + ' ' + c.Apellido1 AS Nombre_Cliente,
    h.Numero AS Numero_Habitacion,
    f.Total,
    f.Metodo_Pago,
    eh.Nombre AS Nombre_Establecimiento
FROM 
    Facturas f
    JOIN Reservaciones r ON f.ID_Reservacion = r.ID_Reservacion
    JOIN Clientes c ON r.ID_Cliente = c.ID_Cliente
    JOIN Habitaciones h ON r.ID_Habitacion = h.ID_Habitacion
    JOIN Habitacion_Tipo ht ON h.ID_Tipo_Habitacion = ht.ID_Tipo_Habitacion
    JOIN Establecimiento_Hospedaje eh ON ht.ID_Establecimiento = eh.ID_Establecimiento;


-- Vista completa de empresas de recreacion 

select * from vw_Empresas_Recreacion
GO
CREATE OR ALTER VIEW vw_Empresas_Recreacion AS
SELECT 
    er.ID_Empresa,
    er.Nombre,
    er.Cedula_Juridica,
    er.Email,
    er.Telefono,
    er.Contacto_Nombre, 
    p.Nombre AS Provincia,
    c.Nombre AS Canton,
    d.Nombre AS Distrito,
    dir.Senas_Exactas,
    (
        SELECT STRING_AGG(ta.Nombre, ', ')
        FROM Empresa_Actividades ea
        JOIN Tipos_Actividad ta ON ea.ID_Tipo_Actividad = ta.ID_Tipo_Actividad
        WHERE ea.ID_Empresa = er.ID_Empresa
    ) AS Actividades_Ofrecidas
FROM 
    Empresas_Recreacion er
    LEFT JOIN Direcciones dir ON er.ID_Direccion = dir.ID_Direccion
    LEFT JOIN Provincias p ON dir.Codigo_Provincia = p.Codigo_Provincia
    LEFT JOIN Cantones c ON dir.Codigo_Provincia = c.Codigo_Provincia 
                         AND dir.Codigo_Canton = c.Codigo_Canton
    LEFT JOIN Distritos d ON dir.Codigo_Provincia = d.Codigo_Provincia 
                          AND dir.Codigo_Canton = d.Codigo_Canton 
                          AND dir.Codigo_Distrito = d.Codigo_Distrito;

GO
CREATE OR ALTER PROCEDURE sp_ObtenerEmpresasRecreacion
AS
BEGIN

    SELECT * 
    FROM vw_Empresas_Recreacion;
END;
GO
EXEC sp_ObtenerEmpresasRecreacion
-- Vista completa de las Compras de Actividades

select * from vw_Compras_Actividades
CREATE OR ALTER VIEW vw_Compras_Actividades AS
SELECT 
    ca.ID_Compra,
    ca.ID_Cliente,
    cl.Nombre + ' ' + cl.Apellido1 AS Nombre_Cliente,
    ta.Nombre AS Tipo_Actividad,
    er.Nombre AS Nombre_Empresa,
    ca.Fecha_Compra,
    ca.Fecha_Actividad,
    ca.Cantidad_Personas,
    ca.Total,
    ca.Metodo_Pago
FROM 
    Compras_Actividades ca
    JOIN Clientes cl ON ca.ID_Cliente = cl.ID_Cliente
    JOIN Empresa_Actividades ea ON ca.ID_Actividad_Empresa = ea.ID_Actividad_Empresa
    JOIN Tipos_Actividad ta ON ea.ID_Tipo_Actividad = ta.ID_Tipo_Actividad
    JOIN Empresas_Recreacion er ON ea.ID_Empresa = er.ID_Empresa;




-- Procedures para Busquedas
go
CREATE OR ALTER PROCEDURE sp_BuscarEstablecimientos
    @Nombre VARCHAR(100) = NULL,
    @Provincia VARCHAR(50) = NULL,
    @Canton VARCHAR(50) = NULL,
    @Servicio VARCHAR(50) = NULL,
    @TipoEstablecimiento VARCHAR(50) = NULL 
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        e.ID_Establecimiento,
        e.Nombre,
        e.Tipo,
        e.Provincia,
        e.Canton,
        e.Telefono1,
        e.Email,
        e.Web_URL,
        (
            SELECT STRING_AGG(s.Nombre, ', ')
            FROM Establecimiento_Servicios es
            JOIN Servicios s ON es.ID_Servicio = s.ID_Servicio
            WHERE es.ID_Establecimiento = e.ID_Establecimiento
            AND (@Servicio IS NULL OR s.Nombre LIKE '%' + @Servicio + '%')
        ) AS Servicios_Ofrecidos
    FROM 
        vw_Establecimientos e
    WHERE 
        (@Nombre IS NULL OR e.Nombre LIKE '%' + @Nombre + '%')
        AND (@Provincia IS NULL OR e.Provincia = @Provincia)
        AND (@Canton IS NULL OR e.Canton = @Canton)
        AND (@TipoEstablecimiento IS NULL OR e.Tipo = @TipoEstablecimiento) 
        AND (
            @Servicio IS NULL OR
            EXISTS (
                SELECT 1
                FROM Establecimiento_Servicios es
                JOIN Servicios s ON es.ID_Servicio = s.ID_Servicio
                WHERE es.ID_Establecimiento = e.ID_Establecimiento
                AND s.Nombre LIKE '%' + @Servicio + '%'
            )
        )
    ORDER BY 
        e.Nombre;
END;

GO
CREATE OR ALTER PROCEDURE sp_BuscarClientes
    @TextoBusqueda VARCHAR(100) = NULL,
    @PaisResidencia VARCHAR(50) = NULL,
    @Provincia VARCHAR(50) = NULL,
    @Canton VARCHAR(50) = NULL,
    @SoloConReservaciones BIT = 0
	
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        c.ID_Cliente,
        c.Nombre + ' ' + c.Apellido1 AS NombreCompleto,
        c.Cedula,
        c.Telefono1,
        c.Email,
        c.Pais_Residencia,
        c.Provincia,
        c.Canton
    FROM 
        vw_Clientes c
    WHERE 
        (
            @TextoBusqueda IS NULL 
            OR c.Nombre LIKE '%' + @TextoBusqueda + '%'
            OR c.Apellido1 LIKE '%' + @TextoBusqueda + '%'
            OR c.Cedula LIKE '%' + @TextoBusqueda + '%'
        )
        AND (@PaisResidencia IS NULL OR c.Pais_Residencia = @PaisResidencia)
        AND (@Provincia IS NULL OR c.Provincia = @Provincia)
        AND (@Canton IS NULL OR c.Canton = @Canton)
        AND (@SoloConReservaciones = 0 OR EXISTS (
            SELECT 1 FROM Reservaciones r WHERE r.ID_Cliente = c.ID_Cliente
        ))
    ORDER BY 
        c.Apellido1, c.Nombre;
END;

-- Procedimiento para la busqueda especifica de Empresas de recreacion

GO
CREATE OR ALTER PROCEDURE sp_BuscarEmpresasRecreacion
    @TextoBusqueda VARCHAR(100) = NULL,
    @TipoActividad VARCHAR(50) = NULL,
    @Provincia VARCHAR(50) = NULL,
    @Canton VARCHAR(50) = NULL,
    @PrecioMax DECIMAL(10,2) = NULL,
    @PrecioMin DECIMAL(10,2) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        v.ID_Empresa,
        v.Nombre,
        v.Cedula_Juridica,
        v.Telefono,
        v.Provincia,
        v.Canton,
        (
            SELECT MIN(ea.Precio)
            FROM Empresa_Actividades ea
            JOIN Tipos_Actividad ta ON ea.ID_Tipo_Actividad = ta.ID_Tipo_Actividad
            WHERE ea.ID_Empresa = v.ID_Empresa
            AND (@TipoActividad IS NULL OR ta.Nombre LIKE '%' + @TipoActividad + '%')
            AND (@PrecioMax IS NULL OR ea.Precio <= @PrecioMax)
            AND (@PrecioMin IS NULL OR ea.Precio >= @PrecioMin)
        ) AS Precio_Minimo,
        (
            SELECT MAX(ea.Precio)
            FROM Empresa_Actividades ea
            JOIN Tipos_Actividad ta ON ea.ID_Tipo_Actividad = ta.ID_Tipo_Actividad
            WHERE ea.ID_Empresa = v.ID_Empresa
            AND (@TipoActividad IS NULL OR ta.Nombre LIKE '%' + @TipoActividad + '%')
            AND (@PrecioMax IS NULL OR ea.Precio <= @PrecioMax)
            AND (@PrecioMin IS NULL OR ea.Precio >= @PrecioMin)
        ) AS Precio_Maximo,
        v.Actividades_Ofrecidas AS Actividades_Principales
    FROM 
        vw_Empresas_Recreacion v
    WHERE 
        (@TextoBusqueda IS NULL OR v.Nombre LIKE '%' + @TextoBusqueda + '%')
        AND (@Provincia IS NULL OR v.Provincia = @Provincia)
        AND (@Canton IS NULL OR v.Canton = @Canton)
    ORDER BY
        v.Nombre;
END;



CREATE OR ALTER PROCEDURE sp_BuscarFacturas
    @NumeroFactura VARCHAR(20) = NULL,
    @NombreCliente VARCHAR(100) = NULL,
    @CedulaCliente VARCHAR(20) = NULL,
    @FechaInicio DATE = NULL,
    @FechaFin DATE = NULL,
    @ID_Establecimiento INT = NULL,
    @MetodoPago VARCHAR(20) = NULL,
    @MontoMinimo DECIMAL(10,2) = NULL,
    @MontoMaximo DECIMAL(10,2) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        f.ID_Factura,
        f.Numero_Factura,
        f.Fecha_Factura,
        r.Numero_Reserva,
        c.Nombre + ' ' + c.Apellido1 AS NombreCliente,
        c.Cedula,
        e.Nombre AS NombreEstablecimiento,
        f.Total,
        f.Metodo_Pago
    FROM 
        Facturas f
        JOIN Reservaciones r ON f.ID_Reservacion = r.ID_Reservacion
        JOIN Clientes c ON r.ID_Cliente = c.ID_Cliente
        JOIN Habitaciones h ON r.ID_Habitacion = h.ID_Habitacion
        JOIN Habitacion_Tipo ht ON h.ID_Tipo_Habitacion = ht.ID_Tipo_Habitacion
        JOIN Establecimiento_Hospedaje e ON ht.ID_Establecimiento = e.ID_Establecimiento
    WHERE 
        (@NumeroFactura IS NULL OR f.Numero_Factura LIKE '%' + @NumeroFactura + '%')
        AND (@NombreCliente IS NULL OR 
            (c.Nombre LIKE '%' + @NombreCliente + '%' OR 
             c.Apellido1 LIKE '%' + @NombreCliente + '%'))
        AND (@CedulaCliente IS NULL OR c.Cedula LIKE '%' + @CedulaCliente + '%')
        AND (@FechaInicio IS NULL OR f.Fecha_Factura >= @FechaInicio)
        AND (@FechaFin IS NULL OR f.Fecha_Factura <= @FechaFin)
        AND (@ID_Establecimiento IS NULL OR e.ID_Establecimiento = @ID_Establecimiento)
        AND (@MetodoPago IS NULL OR f.Metodo_Pago = @MetodoPago)
        AND (@MontoMinimo IS NULL OR f.Total >= @MontoMinimo)
        AND (@MontoMaximo IS NULL OR f.Total <= @MontoMaximo)
    ORDER BY 
        f.Fecha_Factura DESC;
END;

CREATE OR ALTER PROCEDURE sp_BuscarComprasActividades
    @NombreCliente VARCHAR(100) = NULL,
    @CedulaCliente VARCHAR(20) = NULL,
    @NombreActividad VARCHAR(50) = NULL,
    @NombreEmpresa VARCHAR(100) = NULL,
    @FechaInicio DATE = NULL,
    @FechaFin DATE = NULL,
    @FechaActividadInicio DATE = NULL,
    @FechaActividadFin DATE = NULL,
    @MontoMinimo DECIMAL(10,2) = NULL,
    @MontoMaximo DECIMAL(10,2) = NULL,
    @MetodoPago VARCHAR(20) = NULL,
    @ID_EstablecimientoRecomendador INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        ca.ID_Compra,
        c.Nombre + ' ' + c.Apellido1 AS NombreCliente,
        ta.Nombre AS TipoActividad,
        er.Nombre AS NombreEmpresa,
        ca.Fecha_Compra,
        ca.Fecha_Actividad,
        ca.Total,
        ca.Metodo_Pago,
        eh.Nombre AS EstablecimientoRecomendador
    FROM 
        Compras_Actividades ca
        JOIN Clientes c ON ca.ID_Cliente = c.ID_Cliente
        JOIN Empresa_Actividades ea ON ca.ID_Actividad_Empresa = ea.ID_Actividad_Empresa
        JOIN Tipos_Actividad ta ON ea.ID_Tipo_Actividad = ta.ID_Tipo_Actividad
        JOIN Empresas_Recreacion er ON ea.ID_Empresa = er.ID_Empresa
        LEFT JOIN Establecimiento_Socios es ON er.ID_Empresa = es.ID_Empresa_Recreacion
        LEFT JOIN Establecimiento_Hospedaje eh ON es.ID_Establecimiento_Hospedaje = eh.ID_Establecimiento
    WHERE 
        (@NombreCliente IS NULL OR 
            (c.Nombre LIKE '%' + @NombreCliente + '%' OR 
             c.Apellido1 LIKE '%' + @NombreCliente + '%'))
        AND (@CedulaCliente IS NULL OR c.Cedula LIKE '%' + @CedulaCliente + '%')
        AND (@NombreActividad IS NULL OR ta.Nombre LIKE '%' + @NombreActividad + '%')
        AND (@NombreEmpresa IS NULL OR er.Nombre LIKE '%' + @NombreEmpresa + '%')
        AND (@FechaInicio IS NULL OR ca.Fecha_Compra >= @FechaInicio)
        AND (@FechaFin IS NULL OR ca.Fecha_Compra <= @FechaFin)
        AND (@FechaActividadInicio IS NULL OR ca.Fecha_Actividad >= @FechaActividadInicio)
        AND (@FechaActividadFin IS NULL OR ca.Fecha_Actividad <= @FechaActividadFin)
        AND (@MontoMinimo IS NULL OR ca.Total >= @MontoMinimo)
        AND (@MontoMaximo IS NULL OR ca.Total <= @MontoMaximo)
        AND (@MetodoPago IS NULL OR ca.Metodo_Pago = @MetodoPago)
        AND (@ID_EstablecimientoRecomendador IS NULL OR eh.ID_Establecimiento = @ID_EstablecimientoRecomendador)
    ORDER BY 
        ca.Fecha_Compra DESC;
END;
