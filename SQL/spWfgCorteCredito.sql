IF NOT EXISTS(SELECT * FROM SysObjects WHERE Type='U' AND Name ='WfgBitacoraCorteCredito')
	CREATE TABLE WfgBitacoraCorteCredito
	(
		ID					int IDENTITY,
		Empresa				varchar(5),
		Sucursal			int,
		Usuario				varchar(20),
		FechaD				datetime,
		FechaA				datetime,
		ModuloEspecifico	varchar(10),
		Ok					int,
		OkRef				varchar(255)	
	)
GO


IF EXISTS (SELECT * FROM SysObjects WHERE Type='p' AND Name='spWfgCorteCredito')
	DROP PROCEDURE spWfgCorteCredito
GO
CREATE PROCEDURE spWfgCorteCredito
	@Empresa varchar(5),
	@Sucursal	int,
	@Usuario	varchar(20),
	@ModuloEspecifico	varchar(10),
	@ForzarCorte bit

AS
BEGIN	
	DECLARE
		@Ok int,
		@OkRef	varchar(255),
		@ActivarCorteCredito bit,
		@FechaD		datetime,
		@FechaA		datetime,
		@Dia int,
		@DiaCorte int,
		@Procesar bit

	SELECT @ActivarCorteCredito=ActivarCorteCredito, @DiaCorte = DiaCorteCredito
		FROM WfgCfg
		WHERe Empresa=@Empresa
	SELECT @FechaA = GETDATE()
	SELECT @Dia = DATEPART(day, @FechaA)
	SELECT @Procesar=@ForzarCorte
	
	IF @ActivarCorteCredito=1 AND @Dia=ISNULL(@DiaCorte,0)
		SELECT @Procesar = 1
	
	IF @Procesar = 1
	BEGIN--@ActivarCorteCredito=1
		--Asignamos valor a FechaD
		SELECT @FechaD = DATEADD(day,1,MAX(Fecha)) FROM ACDiaCerrado
		IF ISNULL(@FechaD,0)=0
			SELECT @FechaD = '20170101'

		SELECT @FechaA = GETDATE()
		SELECT @Dia = DATEPART(day, @FechaA)
		BEGIN TRANSACTION
			--quitar la siguiente linea en produccion
			--TRUNCATE TABLE ACDiaCerrado
	
			EXEC spACCerrarDia   @Sucursal,@Empresa,@Usuario,@FechaD,@FechaA,@Ok OUTPUT,@OkRef OUTPUT,@ModuloEspecifico

		IF ISNULL(@Ok,0)=0
			COMMIT
		ELSE
		BEGIN
			ROLLBACK
			INSERT INTO WfgBitacoraCorteCredito
				SELECT @Empresa,@Sucursal,@Usuario,@FechaD,@FechaA,@ModuloEspecifico,@Ok,@OkRef
		END
	END--@ActivarCorteCredito=1
END
GO


--BEGIN TRANSACTION
	--EXEC spWfgCorteCredito	'E001','0','INTELISIS','CXC',1
	--SELECT * FROM Cxc
	--	WHERE Mov IN ('Cargo Moratorio','Intereses Vencidos')
	--	ORDER BY ID DESC
	--SELECT * FROM WfgBitacoraCorteCredito
	--IF @@TRANCOUNT>0
	--	ROLLBACK
--SELECT * FROM ACDiaCerrado