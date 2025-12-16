#  ContosoUniversity Code Migration - Master Checklist

**Project:** ContosoUniversity Migration to Azure (.NET 2.1  .NET 8.0)  
**Phase:** Phase 3 - Code Migration  
**Started:** December 10, 2025  
**Target Completion:** 12-14 days

---

##  Migration Overview

### Modules to Migrate
- [ ] 1. ContosoUniversity.Data (Foundation)
- [ ] 2. ContosoUniversity.Common (Shared Services)
- [ ] 3. ContosoUniversity.Web (MVC/Razor Pages)
- [ ] 4. ContosoUniversity.Api (REST API)
- [ ] 5. ContosoUniversity.Spa.React (React SPA)
- [ ] 6. Test Projects (3 projects)

### Pre-Migration Tasks
- [ ] Create backup folder
- [ ] Copy original codebase to backup
- [ ] Create new modernized project folder structure
- [ ] Install required VS Code extensions (.NET 8 SDK, C# Dev Kit, Azure extensions)
- [ ] Verify .NET 8 SDK installed

### Post-Migration Tasks
- [ ] Run all unit tests
- [ ] Verify build succeeds for all projects
- [ ] Document breaking changes
- [ ] Update deployment scripts
- [ ] Create Docker containerization (if needed)
- [ ] Update Report-Status.md

---

##  Detailed Module Checklists

Refer to individual module checklist files:
1. `01-Data-Layer-Checklist.md` - Entity Framework Core & Database
2. `02-Common-Layer-Checklist.md` - Shared services, repositories, messaging
3. `03-Web-App-Checklist.md` - MVC, Razor Pages, Identity migration
4. `04-Api-Checklist.md` - REST API, Swagger, JWT authentication
5. `05-Spa-React-Checklist.md` - React SPA modernization
6. `06-Test-Projects-Checklist.md` - Unit and integration tests

---

##  Critical Issues from AppCat Analysis

### Runtime.0001 - Framework Upgrade (MANDATORY)
- [ ] All 8 projects upgraded from netcoreapp2.1  net8.0
- [ ] SDK version updated in global.json
- [ ] Verify Azure App Service compatibility

### Connection.0001 - Database Migration (REQUIRED)
- [ ] ContosoUniversity.Api - Connection string migrated
- [ ] ContosoUniversity.Spa.React - Connection string migrated
- [ ] ContosoUniversity.Web - Connection string migrated
- [ ] Azure Key Vault integration for secrets

### Scale.0001 - Static Content (OPTIONAL)
- [ ] ContosoUniversity.Api - Static files strategy documented
- [ ] ContosoUniversity.Web - Static files strategy documented

---

##  Breaking Changes to Address

### 1. Framework Changes
- [ ] Replace Microsoft.AspNetCore.App metapackage with individual packages
- [ ] Update IHostingEnvironment  IWebHostEnvironment
- [ ] Migrate Startup.cs to .NET 8 minimal hosting (or keep existing pattern)
- [ ] Update WebHostBuilder  WebApplicationBuilder

### 2. Entity Framework Core
- [ ] Replace ExecuteSqlCommandAsync  ExecuteSqlRawAsync
- [ ] Update FromSql  FromSqlRaw
- [ ] Migrate migration builder methods
- [ ] Update query syntax for breaking changes

### 3. Authentication & Authorization
- [ ] Migrate ASP.NET Core Identity 2.0  8.0
- [ ] Plan Entra ID integration (future phase)
- [ ] Update JWT token generation
- [ ] Update OAuth providers configuration

### 4. Package Updates
- [ ] AutoMapper 3.0.1  13.0+
- [ ] Swashbuckle 1.0.0  6.5+
- [ ] SendGrid 9.9.0  latest
- [ ] Twilio 5.8.0  7.0+
- [ ] React 16.12.0  18+
- [ ] Redux 3.7.2  5.0+
- [ ] Bootstrap 3.4.1  5.3+

---

##  Success Criteria

- [ ] All projects compile without errors
- [ ] All unit tests pass
- [ ] Integration tests pass with in-memory database
- [ ] No deprecated API warnings
- [ ] Code analysis shows no critical issues
- [ ] Application runs locally on .NET 8
- [ ] Configuration migrated to appsettings.json structure
- [ ] Secrets removed from configuration files
- [ ] Migration report completed

---

##  Notes & Issues

**Date** | **Issue/Note** | **Resolution**
---------|----------------|----------------
Dec 10   | Migration started | -

---

##  Related Documents

- Assessment Report: `../reports/Application-Assessment-Report.md`
- Status Report: `../reports/Report-Status.md`
- AppCat Analysis: `../reports/appcat-analysis.json`
