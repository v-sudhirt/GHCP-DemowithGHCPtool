#  Migration Checklist - Data Layer (ContosoUniversity.Data)

**Target Framework:** .NET 9.0  
**Source Framework:** .NET Core 2.1  
**Priority:** HIGH (Foundation layer)

##  Migration Goals
- Upgrade to Entity Framework Core 9.0
- Modernize DbContext configurations
- Update deprecated APIs
- Maintain database schema compatibility
- Azure SQL Database optimization

---

##  Phase 1: Project Setup

- [x] Create ContosoUniversity.Data project (.NET 9.0)
- [ ] Add NuGet packages:
  - [ ] Microsoft.EntityFrameworkCore (9.0.0)
  - [ ] Microsoft.EntityFrameworkCore.SqlServer (9.0.0)
  - [ ] Microsoft.EntityFrameworkCore.Sqlite (9.0.0)
  - [ ] Microsoft.EntityFrameworkCore.InMemory (9.0.0)
  - [ ] Microsoft.EntityFrameworkCore.Design (9.0.0)
  - [ ] Microsoft.AspNetCore.Identity.EntityFrameworkCore (9.0.0)
- [ ] Set up project structure folders:
  - [ ] DbContexts/
  - [ ] Entities/
  - [ ] DTO/
  - [ ] Enums/

---

##  Phase 2: Entity Migration

###  Entities to Migrate (8 entities)
- [ ] BaseEntity.cs
- [ ] Person.cs (base class)
- [ ] Student.cs (inherits Person)
- [ ] Instructor.cs (inherits Person)
- [ ] Course.cs
- [ ] Department.cs
- [ ] Enrollment.cs
- [ ] OfficeAssignment.cs
- [ ] CourseAssignment.cs
- [ ] ApplicationUser.cs (Identity)

**Changes Required:**
- [ ] Review and update data annotations
- [ ] Verify navigation properties
- [ ] Check for deprecated attributes

---

##  Phase 3: DbContext Migration

### DbContexts to Migrate (4 contexts)

#### 1. ApplicationContext.cs
- [ ] Copy from source
- [ ] Update namespace
- [ ] Verify OnModelCreating configuration
- [ ] Update schema handling for Azure SQL
- [ ] Test migrations

#### 2. SecureApplicationContext.cs  
- [ ] Copy from source
- [ ] Update IdentityDbContext base class
- [ ] Update namespace
- [ ] Verify Identity schema configuration
- [ ] Test migrations

#### 3. WebContext.cs
- [ ] Copy from source
- [ ] Combine ApplicationContext + Identity features
- [ ] Update namespace
- [ ] Verify entity configuration
- [ ] Test migrations

#### 4. ApiContext.cs
- [ ] Copy from source
- [ ] Update namespace
- [ ] Verify minimal configuration
- [ ] Test migrations

---

##  Phase 4: DbContext Factory Migration

- [ ] ApplicationContextFactory.cs
  - [ ] Update IDesignTimeDbContextFactory implementation
  - [ ] Remove IHostingEnvironment (use IWebHostEnvironment)
  - [ ] Update configuration loading
  - [ ] Azure SQL connection string support

- [ ] SecureApplicationContextFactory.cs
  - [ ] Update IDesignTimeDbContextFactory implementation
  - [ ] Configuration modernization
  - [ ] Azure SQL support

---

##  Phase 5: Configuration Classes

- [ ] DbContextConfig.cs
  - [ ] Migrate entity configurations
  - [ ] Update Fluent API calls (check for breaking changes)
  - [ ] Schema configuration for Azure SQL

- [ ] OperatingSystem.cs
  - [ ] Update platform detection (use RuntimeInformation)
  - [ ] Modern .NET platform APIs

---

##  Phase 6: DTO Migration

- [ ] CourseDTO.cs
- [ ] StudentDTO.cs
- [ ] InstructorDTO.cs
- [ ] DepartmentDTO.cs
- [ ] EnrollmentDTO.cs
- [ ] OfficeAssignmentDTO.cs
- [ ] CourseAssignmentsDTO.cs

---

##  Phase 7: Enums Migration

- [ ] Grade.cs

---

##  Phase 8: Breaking Changes Resolution

### Known EF Core 2.1  9.0 Breaking Changes

- [ ] **ExecuteSqlCommandAsync**  ExecuteSqlRawAsync/ExecuteSqlInterpolatedAsync
- [ ] **FromSql**  FromSqlRaw/FromSqlInterpolated
- [ ] **Migration history table** configuration syntax
- [ ] **Owned entity types** configuration changes
- [ ] **Query types** removed (use keyless entity types)
- [ ] **HasOne().WithOne()** requires explicit foreign key
- [ ] **UseInternalServiceProvider** usage review

---

##  Phase 9: Azure SQL Optimization

- [ ] Connection resiliency configuration
- [ ] Retry policies for transient failures
- [ ] Connection string format for Azure SQL
- [ ] Managed Identity authentication support
- [ ] Performance optimization (indexes, query hints)

---

##  Phase 10: Testing

- [ ] Build project successfully
- [ ] Run get_errors to check for issues
- [ ] Create test migrations
- [ ] Verify schema generation
- [ ] Test against LocalDB
- [ ] Test against Azure SQL Database (dev instance)

---

##  Progress Tracking

| Task Category | Total | Complete | Percentage |
|--------------|-------|----------|------------|
| Project Setup | 3 | 1 | 33% |
| Entities | 10 | 0 | 0% |
| DbContexts | 4 | 0 | 0% |
| Factories | 2 | 0 | 0% |
| Configuration | 2 | 0 | 0% |
| DTOs | 7 | 0 | 0% |
| Enums | 1 | 0 | 0% |
| Breaking Changes | 7 | 0 | 0% |
| Azure Optimization | 5 | 0 | 0% |
| Testing | 6 | 0 | 0% |
| **TOTAL** | **47** | **1** | **2%** |

---

##  Critical Issues

| Issue | Severity | Status |
|-------|----------|--------|
| EF Core version jump (2.1  9.0) | HIGH |  Planned |
| Migration history compatibility | MEDIUM |  Planned |
| Platform detection API changes | MEDIUM |  Planned |
| Azure SQL connection format | HIGH |  Planned |

---

##  Notes

- Keep backup folder unchanged as reference
- Test each DbContext independently
- Verify migrations work with both SQL Server and Azure SQL
- Document any schema changes required
- Maintain backward compatibility where possible
