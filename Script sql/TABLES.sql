CREATE DATABASE PY1BD;
GO
USE PY1BD;
GO

-- Tablas de Direcciones 
-- Tabla Provincia 
CREATE TABLE Provincias (
    Codigo_Provincia CHAR(2) PRIMARY KEY,
    Nombre VARCHAR(20) NOT NULL
);

-- Tabla Canton
CREATE TABLE Cantones (
    Codigo_Provincia CHAR(2),
    Codigo_Canton CHAR(2),
    Nombre VARCHAR(50) NOT NULL,
    PRIMARY KEY (Codigo_Provincia, Codigo_Canton),
    FOREIGN KEY (Codigo_Provincia) REFERENCES Provincias(Codigo_Provincia)
);

-- Tabla Distrito
CREATE TABLE Distritos (
    Codigo_Provincia CHAR(2),
    Codigo_Canton CHAR(2),
    Codigo_Distrito CHAR(2),
    Nombre VARCHAR(50) NOT NULL,
    PRIMARY KEY (Codigo_Provincia, Codigo_Canton, Codigo_Distrito),
    FOREIGN KEY (Codigo_Provincia, Codigo_Canton) REFERENCES Cantones(Codigo_Provincia, Codigo_Canton)
);

-- Tabla Barrio
CREATE TABLE Barrios (
    Codigo_Provincia CHAR(2),
    Codigo_Canton CHAR(2),
    Codigo_Distrito CHAR(2),
    Codigo_Barrio CHAR(2),
    Nombre VARCHAR(50) NOT NULL,
    PRIMARY KEY (Codigo_Provincia, Codigo_Canton, Codigo_Distrito, Codigo_Barrio),
    FOREIGN KEY (Codigo_Provincia, Codigo_Canton, Codigo_Distrito) 
        REFERENCES Distritos(Codigo_Provincia, Codigo_Canton, Codigo_Distrito)
);

-- Tabla de Direcciones
CREATE TABLE Direcciones (
    ID_Direccion INT PRIMARY KEY IDENTITY(1,1),
    Codigo_Provincia CHAR(2),
    Codigo_Canton CHAR(2),
    Codigo_Distrito CHAR(2),
    Codigo_Barrio CHAR(2),
    Senas_Exactas VARCHAR(200),
    GPS VARCHAR(100),
    FOREIGN KEY (Codigo_Provincia, Codigo_Canton, Codigo_Distrito, Codigo_Barrio) 
        REFERENCES barrios(Codigo_Provincia, Codigo_Canton, Codigo_Distrito, Codigo_Barrio)
);

CREATE INDEX IX_Direcciones_Ubicacion ON Direcciones(Codigo_Provincia, Codigo_Canton, Codigo_Distrito, Codigo_Barrio);

CREATE TABLE Establecimiento_Hospedaje (
	-- Identificacion
    ID_Establecimiento INT PRIMARY KEY IDENTITY(1,1),
    Nombre VARCHAR(100) NOT NULL,
    Cedula_Juridica VARCHAR(20) UNIQUE NOT NULL,
    Tipo VARCHAR(50) CHECK (Tipo IN ('Hotel', 'Hostal', 'Casa', 'Departamento', 'Cuarto compartido', 'Cabaña')),
	--Direccion
    ID_Direccion INT NOT NULL,
	--Telefonos
    Telefono1 VARCHAR(20),
    Telefono2 VARCHAR(20),
	--Email y Web
    Email VARCHAR(100),
    Web_URL VARCHAR(100),
	-- Redes sociales
    Facebook_URL VARCHAR(100),
    Instagram_URL VARCHAR(100),
	Youtube_URL VARCHAR(100),
	Tiktok_URL VARCHAR(100),
	Airbnb_URL VARCHAR(100),
	THREADS_URL VARCHAR(100),
	X_URL VARCHAR(100),
	FOREIGN KEY (ID_Direccion) REFERENCES Direcciones(ID_Direccion)
);

CREATE INDEX IX_Establecimiento_Nombre ON Establecimiento_Hospedaje(Nombre);


CREATE TABLE Servicios (
    ID_Servicio INT PRIMARY KEY IDENTITY(1,1),
    Nombre VARCHAR(50) NOT NULL -- Ej: Piscina, Wifi, Parqueo
);

CREATE TABLE Establecimiento_Servicios (
    ID_Establecimiento INT FOREIGN KEY REFERENCES Establecimiento_Hospedaje(ID_Establecimiento),
    ID_Servicio INT FOREIGN KEY REFERENCES Servicios(ID_Servicio),
    PRIMARY KEY (ID_Establecimiento, ID_Servicio)
);


CREATE TABLE Habitacion_Tipo (
    ID_Tipo_Habitacion INT PRIMARY KEY IDENTITY(1,1),
    ID_Establecimiento INT FOREIGN KEY REFERENCES Establecimiento_Hospedaje(ID_Establecimiento),
    Nombre VARCHAR(50) NOT NULL,
    Descripcion TEXT,
    Tipo_Cama VARCHAR(50),
    Precio DECIMAL(10,2) NOT NULL,
	Cantidad INT NOT NULL
);
CREATE INDEX IX_HabitacionTipo_Establecimiento ON Habitacion_Tipo(ID_Establecimiento);

CREATE TABLE Comodidades (
    ID_Comodidad INT PRIMARY KEY IDENTITY(1,1),
    Nombre VARCHAR(50) NOT NULL 
);



CREATE TABLE Habitaciones (
    ID_Habitacion INT PRIMARY KEY IDENTITY(1,1),
    ID_Tipo_Habitacion INT NOT NULL,
    Numero VARCHAR(10) NOT NULL,
    Estado VARCHAR(20) NOT NULL 
        CONSTRAINT DF_Habitacion_Estado DEFAULT 'Disponible'
        CONSTRAINT CK_Habitacion_Estado CHECK (Estado IN ('Disponible', 'Ocupada', 'Reservada')),
   
    FOREIGN KEY (ID_Tipo_Habitacion) REFERENCES Habitacion_Tipo(ID_Tipo_Habitacion),
    CONSTRAINT UQ_Habitacion_Numero UNIQUE (ID_Tipo_Habitacion, Numero) -- Este Unique evita que se repitan numero de habitacion especeificamente por tipo de habitacion
);


CREATE TABLE Clientes (
    ID_Cliente INT PRIMARY KEY IDENTITY(1,1),
    Nombre VARCHAR(50) NOT NULL,
    Apellido1 VARCHAR(50) NOT NULL,
    Apellido2 VARCHAR(50),
    Fecha_Nacimiento DATE NOT NULL,
    Cedula VARCHAR(20) UNIQUE NOT NULL,
    Pais_Residencia VARCHAR(50) NOT NULL,
    ID_Direccion INT,
    Telefono1 VARCHAR(20),
    Telefono2 VARCHAR(20),
    Telefono3 VARCHAR(20),
    Email VARCHAR(100)
);

CREATE TABLE Reservaciones (
    ID_Reservacion INT PRIMARY KEY IDENTITY(1,1),
    ID_Cliente INT NOT NULL,
    ID_Habitacion INT NOT NULL,
    Fecha_Ingreso DATE NOT NULL,
    Hora_Ingreso TIME NOT NULL DEFAULT '14:00:00',  -- 2 PM por defecto
    Fecha_Salida DATE NOT NULL,
    Hora_Salida TIME NOT NULL DEFAULT '12:00:00',   -- 12 PM por defecto
    Cantidad_Personas INT NOT NULL,
    Tiene_Vehiculo BIT NOT NULL DEFAULT 0,
    Activa BIT NOT NULL DEFAULT 1,
    Numero_Reserva AS ('RES-' + CAST(ID_Reservacion AS VARCHAR(10))) PERSISTED,
    CONSTRAINT FK_Reservaciones_Clientes FOREIGN KEY (ID_Cliente) REFERENCES Clientes(ID_Cliente),
    CONSTRAINT FK_Reservaciones_Habitacion FOREIGN KEY (ID_Habitacion) REFERENCES Habitaciones(ID_Habitacion),

    CONSTRAINT CHK_Fechas_Validas CHECK (
        (Fecha_Ingreso < Fecha_Salida) OR 
        (Fecha_Ingreso = Fecha_Salida AND Hora_Ingreso < Hora_Salida)
    )
);
CREATE INDEX IX_Reservaciones_Cliente ON Reservaciones(ID_Cliente);
CREATE INDEX IX_Reservaciones_Activa ON Reservaciones(Activa) WHERE Activa = 1;

-- Evita que choquen las reservaciones 
CREATE UNIQUE INDEX IX_Reservacion_Habitacion_Fechas 
ON Reservaciones(ID_Habitacion, Fecha_Ingreso, Fecha_Salida)
WHERE Activa = 1;
GO


CREATE TABLE Facturas (
    ID_Factura INT PRIMARY KEY IDENTITY(1,1),
    ID_Reservacion INT NOT NULL,
    Fecha_Factura DATETIME NOT NULL DEFAULT GETDATE(),
    Subtotal DECIMAL(10,2) NOT NULL,
    Impuestos DECIMAL(10,2) NOT NULL,
    Total DECIMAL(10,2) NOT NULL,
    Metodo_Pago VARCHAR(20) NOT NULL CHECK (Metodo_Pago IN ('Efectivo', 'Tarjeta Crédito', 'Tarjeta Débito', 'Transferencia')),
    Detalles VARCHAR(200) NULL,
    Numero_Factura AS ('FAC-' + CAST(YEAR(GETDATE()) AS VARCHAR(4)) + '-' + RIGHT('00000' + CAST(ID_Factura AS VARCHAR(5)), 5)), -- tiene la fecha y el numero
    Pendiente_Pago BIT NOT NULL DEFAULT 1,
    CONSTRAINT FK_Facturas_Reservaciones FOREIGN KEY (ID_Reservacion) REFERENCES Reservaciones(ID_Reservacion)
);
CREATE INDEX IX_Facturas_Reservacion ON Facturas(ID_Reservacion);

CREATE TABLE Empresas_Recreacion (
    ID_Empresa INT PRIMARY KEY IDENTITY(1,1),
    Nombre VARCHAR(100) NOT NULL,
    Cedula_Juridica VARCHAR(20) UNIQUE NOT NULL,
    Email VARCHAR(100),
    Telefono VARCHAR(20),
    Contacto_Nombre VARCHAR(100),
    ID_Direccion INT,
    Descripcion TEXT,
    FOREIGN KEY (ID_Direccion) REFERENCES Direcciones(ID_Direccion)
);

CREATE INDEX IX_EmpresasRecreacion_Nombre ON Empresas_Recreacion(Nombre);

CREATE TABLE Tipos_Actividad (
    ID_Tipo_Actividad INT PRIMARY KEY IDENTITY(1,1),
    Nombre VARCHAR(50) NOT NULL 
);

CREATE TABLE Empresa_Actividades (
    ID_Actividad_Empresa INT PRIMARY KEY IDENTITY(1,1),
    ID_Empresa INT NOT NULL FOREIGN KEY REFERENCES Empresas_Recreacion(ID_Empresa),
    ID_Tipo_Actividad INT NOT NULL FOREIGN KEY REFERENCES Tipos_Actividad(ID_Tipo_Actividad),
    Precio DECIMAL(10,2) NOT NULL,
    Descripcion TEXT,
    
    CONSTRAINT UQ_Empresa_TipoActividad UNIQUE (ID_Empresa, ID_Tipo_Actividad)
);

CREATE TABLE Compras_Actividades (
    ID_Compra INT PRIMARY KEY IDENTITY(1,1),
    ID_Cliente INT NOT NULL FOREIGN KEY REFERENCES Clientes(ID_Cliente),
    ID_Actividad_Empresa INT NOT NULL FOREIGN KEY REFERENCES Empresa_Actividades(ID_Actividad_Empresa),
    Fecha_Compra DATETIME NOT NULL DEFAULT GETDATE(),
    Fecha_Actividad DATE NOT NULL,
    Cantidad_Personas INT NOT NULL DEFAULT 1,
    Subtotal DECIMAL(10,2) NOT NULL,
    Impuestos DECIMAL(10,2) NOT NULL,
    Total DECIMAL(10,2) NOT NULL,
    Metodo_Pago VARCHAR(20) NOT NULL CHECK (Metodo_Pago IN ('Efectivo', 'Tarjeta Crédito', 'Tarjeta Débito', 'Transferencia'))
);


CREATE TABLE Establecimiento_Socios (
    ID_Asociacion INT PRIMARY KEY IDENTITY(1,1),
    ID_Establecimiento_Hospedaje INT NOT NULL,
    ID_Empresa_Recreacion INT NOT NULL,
    Comision DECIMAL(5,2) NULL, 
    Descripcion_Recomendacion VARCHAR(255) NULL,
    
    CONSTRAINT FK_Establecimiento_Hospedaje 
        FOREIGN KEY (ID_Establecimiento_Hospedaje) 
        REFERENCES Establecimiento_Hospedaje(ID_Establecimiento),
    
    CONSTRAINT FK_Empresa_Recreacion 
        FOREIGN KEY (ID_Empresa_Recreacion) 
        REFERENCES Empresas_Recreacion(ID_Empresa),
    
    CONSTRAINT UQ_Asociacion_Establecimientos 
        UNIQUE (ID_Establecimiento_Hospedaje, ID_Empresa_Recreacion)
);







