CREATE SCHEMA stg;
GO
CREATE SCHEMA dw;
GO
CREATE SCHEMA dm;
GO

SELECT name
FROM sys.schemas
WHERE name IN ('stg','dw','dm');

---Dimention tables
CREATE TABLE dw.DimDate (
    DateKey        INT        NOT NULL PRIMARY KEY,
    [Date]         DATE       NOT NULL,
    [Year]         SMALLINT   NOT NULL,
    [Month]        TINYINT    NOT NULL,
    MonthName      VARCHAR(10) NOT NULL,
    [Quarter]      TINYINT    NOT NULL,
    WeekOfYear     TINYINT    NOT NULL,
    DayOfMonth     TINYINT    NOT NULL,
    DayName        VARCHAR(10) NOT NULL,
    IsWeekend      BIT        NOT NULL
);
GO

CREATE TABLE dw.DimProject (
    ProjectKey        INT IDENTITY(1,1) PRIMARY KEY,
    ProjectCode       VARCHAR(30)  NOT NULL,
    ProjectName       VARCHAR(200) NOT NULL,
    Region            VARCHAR(80)  NOT NULL,
    BusinessUnit      VARCHAR(80)  NOT NULL,
    ContractType      VARCHAR(50)  NULL,
    ClientName        VARCHAR(150) NULL,
    StartDate         DATE         NULL,
    PlannedEndDate    DATE         NULL,
    Status            VARCHAR(30)  NOT NULL,
    ProjectManager    VARCHAR(120) NULL,
    CostCentre        VARCHAR(40)  NULL,
    EffectiveFrom     DATE         NOT NULL DEFAULT (GETDATE()),
    EffectiveTo       DATE         NULL,
    IsCurrent         BIT          NOT NULL DEFAULT (1)
);
GO

CREATE UNIQUE INDEX UX_DimProject_Current
ON dw.DimProject(ProjectCode)
WHERE IsCurrent = 1;
GO

CREATE TABLE dw.DimSupplier (
    SupplierKey     INT IDENTITY(1,1) PRIMARY KEY,
    SupplierCode    VARCHAR(40)  NOT NULL,
    SupplierName    VARCHAR(200) NOT NULL,
    SupplierType    VARCHAR(60)  NULL,
    Country         VARCHAR(80)  NULL,
    IsPreferred     BIT          NOT NULL DEFAULT (0),
    EffectiveFrom   DATE         NOT NULL DEFAULT (GETDATE()),
    EffectiveTo     DATE         NULL,
    IsCurrent       BIT          NOT NULL DEFAULT (1)
);
GO

CREATE UNIQUE INDEX UX_DimSupplier_Current
ON dw.DimSupplier(SupplierCode)
WHERE IsCurrent = 1;
GO

CREATE TABLE dw.DimPackage (
    PackageKey        INT IDENTITY(1,1) PRIMARY KEY,
    PackageCode       VARCHAR(40)  NOT NULL,
    PackageName       VARCHAR(200) NOT NULL,
    Workstream        VARCHAR(80)  NULL,
    RiskCategory      VARCHAR(40)  NULL,
    EffectiveFrom     DATE         NOT NULL DEFAULT (GETDATE()),
    EffectiveTo       DATE         NULL,
    IsCurrent         BIT          NOT NULL DEFAULT (1)
);
GO

CREATE UNIQUE INDEX UX_DimPackage_Current
ON dw.DimPackage(PackageCode)
WHERE IsCurrent = 1;
GO


----Fact table
CREATE TABLE dw.FactCost (
    FactCostID        BIGINT IDENTITY(1,1) PRIMARY KEY,
    DateKey           INT NOT NULL,
    ProjectKey        INT NOT NULL,
    PackageKey        INT NOT NULL,
    SupplierKey       INT NOT NULL,
    CurrencyCode      CHAR(3) NOT NULL DEFAULT ('GBP'),
    CommittedCost     DECIMAL(18,2) NOT NULL DEFAULT (0),
    ActualCost        DECIMAL(18,2) NOT NULL DEFAULT (0),
    ApprovedVariation DECIMAL(18,2) NOT NULL DEFAULT (0),
    PendingVariation  DECIMAL(18,2) NOT NULL DEFAULT (0),
    ForecastEAC       DECIMAL(18,2) NULL,
    SourceSystem      VARCHAR(50) NULL,
    LoadDTS           DATETIME2   NOT NULL DEFAULT (SYSDATETIME())
);
GO

ALTER TABLE dw.FactCost
ADD CONSTRAINT FK_FactCost_Date
    FOREIGN KEY (DateKey) REFERENCES dw.DimDate(DateKey);

ALTER TABLE dw.FactCost
ADD CONSTRAINT FK_FactCost_Project
    FOREIGN KEY (ProjectKey) REFERENCES dw.DimProject(ProjectKey);

ALTER TABLE dw.FactCost
ADD CONSTRAINT FK_FactCost_Package
    FOREIGN KEY (PackageKey) REFERENCES dw.DimPackage(PackageKey);

ALTER TABLE dw.FactCost
ADD CONSTRAINT FK_FactCost_Supplier
    FOREIGN KEY (SupplierKey) REFERENCES dw.DimSupplier(SupplierKey);
GO



---check
SELECT s.name AS schema_name, t.name AS table_name
FROM sys.tables t
JOIN sys.schemas s ON s.schema_id = t.schema_id
ORDER BY s.name, t.name;

---deleting and creating again

-- 1) Schemas (safe if they already exist)
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name='stg') EXEC('CREATE SCHEMA stg');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name='dw')  EXEC('CREATE SCHEMA dw');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name='dm')  EXEC('CREATE SCHEMA dm');
GO

-- 2) Dimension tables
IF OBJECT_ID('dw.DimDate','U') IS NULL
BEGIN
    CREATE TABLE dw.DimDate (
        DateKey        INT         NOT NULL PRIMARY KEY,
        [Date]         DATE        NOT NULL,
        [Year]         SMALLINT    NOT NULL,
        [Month]        TINYINT     NOT NULL,
        MonthName      VARCHAR(10) NOT NULL,
        [Quarter]      TINYINT     NOT NULL,
        WeekOfYear     TINYINT     NOT NULL,
        DayOfMonth     TINYINT     NOT NULL,
        DayName        VARCHAR(10) NOT NULL,
        IsWeekend      BIT         NOT NULL
    );
END
GO

IF OBJECT_ID('dw.DimProject','U') IS NULL
BEGIN
    CREATE TABLE dw.DimProject (
        ProjectKey        INT IDENTITY(1,1) PRIMARY KEY,
        ProjectCode       VARCHAR(30)  NOT NULL,
        ProjectName       VARCHAR(200) NOT NULL,
        Region            VARCHAR(80)  NOT NULL,
        BusinessUnit      VARCHAR(80)  NOT NULL,
        ContractType      VARCHAR(50)  NULL,
        ClientName        VARCHAR(150) NULL,
        StartDate         DATE         NULL,
        PlannedEndDate    DATE         NULL,
        Status            VARCHAR(30)  NOT NULL,
        ProjectManager    VARCHAR(120) NULL,
        CostCentre        VARCHAR(40)  NULL,
        EffectiveFrom     DATE         NOT NULL DEFAULT (GETDATE()),
        EffectiveTo       DATE         NULL,
        IsCurrent         BIT          NOT NULL DEFAULT (1)
    );

    CREATE UNIQUE INDEX UX_DimProject_Current
    ON dw.DimProject(ProjectCode)
    WHERE IsCurrent = 1;
END
GO

IF OBJECT_ID('dw.DimSupplier','U') IS NULL
BEGIN
    CREATE TABLE dw.DimSupplier (
        SupplierKey     INT IDENTITY(1,1) PRIMARY KEY,
        SupplierCode    VARCHAR(40)  NOT NULL,
        SupplierName    VARCHAR(200) NOT NULL,
        SupplierType    VARCHAR(60)  NULL,
        Country         VARCHAR(80)  NULL,
        IsPreferred     BIT          NOT NULL DEFAULT (0),
        EffectiveFrom   DATE         NOT NULL DEFAULT (GETDATE()),
        EffectiveTo     DATE         NULL,
        IsCurrent       BIT          NOT NULL DEFAULT (1)
    );

    CREATE UNIQUE INDEX UX_DimSupplier_Current
    ON dw.DimSupplier(SupplierCode)
    WHERE IsCurrent = 1;
END
GO

IF OBJECT_ID('dw.DimPackage','U') IS NULL
BEGIN
    CREATE TABLE dw.DimPackage (
        PackageKey        INT IDENTITY(1,1) PRIMARY KEY,
        PackageCode       VARCHAR(40)  NOT NULL,
        PackageName       VARCHAR(200) NOT NULL,
        Workstream        VARCHAR(80)  NULL,
        RiskCategory      VARCHAR(40)  NULL,
        EffectiveFrom     DATE         NOT NULL DEFAULT (GETDATE()),
        EffectiveTo       DATE         NULL,
        IsCurrent         BIT          NOT NULL DEFAULT (1)
    );

    CREATE UNIQUE INDEX UX_DimPackage_Current
    ON dw.DimPackage(PackageCode)
    WHERE IsCurrent = 1;
END
GO

-- 3) Fact table
IF OBJECT_ID('dw.FactCost','U') IS NULL
BEGIN
    CREATE TABLE dw.FactCost (
        FactCostID        BIGINT IDENTITY(1,1) PRIMARY KEY,
        DateKey           INT NOT NULL,
        ProjectKey        INT NOT NULL,
        PackageKey        INT NOT NULL,
        SupplierKey       INT NOT NULL,
        CurrencyCode      CHAR(3) NOT NULL DEFAULT ('GBP'),
        CommittedCost     DECIMAL(18,2) NOT NULL DEFAULT (0),
        ActualCost        DECIMAL(18,2) NOT NULL DEFAULT (0),
        ApprovedVariation DECIMAL(18,2) NOT NULL DEFAULT (0),
        PendingVariation  DECIMAL(18,2) NOT NULL DEFAULT (0),
        ForecastEAC       DECIMAL(18,2) NULL,
        SourceSystem      VARCHAR(50) NULL,
        LoadDTS           DATETIME2   NOT NULL DEFAULT (SYSDATETIME())
    );

    ALTER TABLE dw.FactCost
    ADD CONSTRAINT FK_FactCost_Date
        FOREIGN KEY (DateKey) REFERENCES dw.DimDate(DateKey);

    ALTER TABLE dw.FactCost
    ADD CONSTRAINT FK_FactCost_Project
        FOREIGN KEY (ProjectKey) REFERENCES dw.DimProject(ProjectKey);

    ALTER TABLE dw.FactCost
    ADD CONSTRAINT FK_FactCost_Package
        FOREIGN KEY (PackageKey) REFERENCES dw.DimPackage(PackageKey);

    ALTER TABLE dw.FactCost
    ADD CONSTRAINT FK_FactCost_Supplier
        FOREIGN KEY (SupplierKey) REFERENCES dw.DimSupplier(SupplierKey);
END
GO

---verify
SELECT s.name AS schema_name, t.name AS table_name
FROM sys.tables t
JOIN sys.schemas s ON s.schema_id = t.schema_id
ORDER BY s.name, t.name;

USE vwuk_analytics_db;
GO

--- add loadkey

USE vwuk_analytics_db;
GO

ALTER TABLE dw.FactCost
ADD LoadKey VARCHAR(100) NULL;
GO

---unique filtered key
USE vwuk_analytics_db;
GO

CREATE UNIQUE INDEX UX_FactCost_LoadKey
ON dw.FactCost(LoadKey)
WHERE LoadKey IS NOT NULL;
GO

SELECT name
FROM sys.columns
WHERE object_id = OBJECT_ID('dw.FactCost')
  AND name = 'LoadKey';


  ---one single table
  USE vwuk_analytics_db;
GO

CREATE OR ALTER VIEW dm.vw_CostReporting AS
SELECT
    d.[Date]                          AS [Date],
    d.[Year],
    d.[Month],
    d.MonthName,
    d.[Quarter],
    d.WeekOfYear,

    p.ProjectCode,
    p.ProjectName,
    p.Region,
    p.BusinessUnit,
    p.ContractType,
    p.ClientName,
    p.Status        AS ProjectStatus,
    p.ProjectManager,
    p.CostCentre,

    pk.PackageCode,
    pk.PackageName,
    pk.Workstream,
    pk.RiskCategory,

    s.SupplierCode,
    s.SupplierName,
    s.SupplierType,
    s.Country        AS SupplierCountry,
    s.IsPreferred,

    f.CurrencyCode,
    f.CommittedCost,
    f.ActualCost,
    f.ApprovedVariation,
    f.PendingVariation,
    f.ForecastEAC,

    -- useful derived fields
    (f.ActualCost - f.CommittedCost)                           AS Variance_Actual_vs_Comm,
    (f.ForecastEAC - (f.CommittedCost + f.ApprovedVariation))  AS Variance_EAC_vs_Budget,
    (f.CommittedCost + f.ApprovedVariation)                    AS BudgetWithApprovedVar,

    f.SourceSystem,
    f.LoadKey
FROM dw.FactCost f
JOIN dw.DimDate d
    ON f.DateKey = d.DateKey
JOIN dw.DimProject p
    ON f.ProjectKey = p.ProjectKey AND p.IsCurrent = 1
JOIN dw.DimPackage pk
    ON f.PackageKey = pk.PackageKey AND pk.IsCurrent = 1
JOIN dw.DimSupplier s
    ON f.SupplierKey = s.SupplierKey AND s.IsCurrent = 1;
GO


select * from [dm].[vw_CostReporting]