/****** Object:  Table [dbo].[RevaluacionDolares]    Script Date: 11/06/2015 11:02:58 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RevaluacionDolares]') AND type in (N'U'))
DROP TABLE [dbo].[RevaluacionDolares]
GO

CREATE TABLE [dbo].[RevaluacionDolares](
	[Empresa] [varchar](5) NULL,
	[Sucursal] [int] NULL,
	[CtaComp] [varchar](20) NULL,
	[CtaDolar] [varchar](20) NULL,
	[SaldoCtaDolar] [float] NULL
) ON [PRIMARY]

GO

/****** Object:  Table [dbo].[RevaluacionDolaresCalc]    Script Date: 11/06/2015 11:03:36 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RevaluacionDolaresCalc]') AND type in (N'U'))
DROP TABLE [dbo].[RevaluacionDolaresCalc]
GO

CREATE TABLE [dbo].[RevaluacionDolaresCalc](
	[Empresa] [varchar](5) NULL,
	[Sucursal] [int] NULL,
	[CtaComp] [varchar](20) NULL,
	[Cargo] [float] NULL,
	[Abono] [float] NULL,
	[SaldoCtaDolar] [float] NULL,
	[SaldoCtaComp] [float] NULL,
	[CalcCtaComp] [float] NULL,
	[AjusteComp] [float] NULL,
	[EsAcreedora] [bit] NULL
) ON [PRIMARY]

GO

/****** Object:  Table [dbo].[RevaluacionDolaresCtasUP]    Script Date: 11/06/2015 11:04:03 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RevaluacionDolaresCtasUP]') AND type in (N'U'))
DROP TABLE [dbo].[RevaluacionDolaresCtasUP]
GO

CREATE TABLE [dbo].[RevaluacionDolaresCtasUP](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Empresa] [varchar](5) NULL,
	[Sucursal] [int] NULL,
	[CtaUtilidad] [varchar](20) NULL,
	[CtaPerdida] [varchar](20) NULL,
	[GenerarPoliza] [bit] NULL,
	[TipoCambio] [float] NULL,
	[Ejercicio] [int] NULL,
	[Periodo] [int] NULL,
	[Utilidad] [float] NULL,
	[Perdida] [float] NULL
) ON [PRIMARY]

GO

/****** Object:  Table [dbo].[RevaluacionDolaresHist]    Script Date: 11/06/2015 11:04:44 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RevaluacionDolaresHist]') AND type in (N'U'))
DROP TABLE [dbo].[RevaluacionDolaresHist]
GO

CREATE TABLE [dbo].[RevaluacionDolaresHist](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Empresa] [varchar](5) NULL,
	[FechaRegistro] [datetime] NULL,
	[CtaComp] [varchar](20) NULL,
	[TipoCambio] [float] NULL,
	[Cargo] [float] NULL,
	[Abono] [float] NULL,
	[Ejercicio] [int] NULL,
	[Periodo] [int] NULL
) ON [PRIMARY]

GO

