USE [master]
GO


CREATE LOGIN admin WITH PASSWORD = 'admi123', 
    CHECK_POLICY = OFF, 
    DEFAULT_DATABASE = [administracion_ccss]
GO

ALTER SERVER ROLE [sysadmin] ADD MEMBER [diegopAdmin]
GO




