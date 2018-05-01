/****** Object:  View [dbo].[CtaCont]    Script Date: 11/06/2015 11:27:02 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[CtaCont]'))
DROP VIEW [dbo].[CtaCont]
GO

	CREATE VIEW [dbo].[CtaCont] AS
	SELECT *
	FROM Cta

GO


