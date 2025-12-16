#  Common & Data Layer Migration Checklist

**Module:** ContosoUniversity.Common + ContosoUniversity.Data  
**Priority:** HIGH (Foundation Layer)  
**Estimated Effort:** 2-3 days  
**Status:**  Not Started

---

##  Migration Goals
-  Upgrade Entity Framework Core 2.1  9.0
-  Migrate Repository pattern to modern EF Core practices
-  Update deprecated APIs (`ExecuteSqlCommandAsync`  `ExecuteSqlRawAsync`)
-  Modernize DbContext configurations
-  Update dependency injection patterns
-  Azure SQL Database optimization

---

##  Phase 1: Package Dependencies

### ContosoUniversity.Data Project
- [ ]  **Microsoft.EntityFrameworkCore** (9.0.0)
- [ ]  **Microsoft.EntityFrameworkCore.SqlServer** (9.0.0)
- [ ]  **Microsoft.EntityFrameworkCore.Sqlite** (9.0.0)
- [ ]  **Microsoft.EntityFrameworkCore.InMemory** (9.0.0)
- [ ]  **Microsoft.EntityFrameworkCore.Design** (9.0.0)
- [ ]  **Microsoft.AspNetCore.Identity.EntityFrameworkCore** (9.0.0)

### ContosoUniversity.Common Project
- [ ]  **AutoMapper.Extensions.Microsoft.DependencyInjection** (13.0+)
- [ ]  **SendGrid** (latest)
- [ ]  **Twilio** (7.0+)
- [ ]  **Microsoft.Extensions.Configuration** (9.0.0)
- [ ]  **Microsoft.Extensions.DependencyInjection** (9.0.0)

---

##  Phase 2: Entities Migration

### Copy Entities (No Breaking Changes Expected)
- [ ] Copy `Entities/BaseEntity.cs`
- [ ] Copy `Entities/Course.cs`
- [ ] Copy `Entities/Student.cs`
- [ ] Copy `Entities/Instructor.cs`
- [ ] Copy `Entities/Department.cs`
- [ ] Copy `Entities/Enrollment.cs`
- [ ] Copy `Entities/OfficeAssignment.cs`
- [ ] Copy `Entities/CourseAssignment.cs`
- [ ] Copy `Entities/Person.cs`
- [ ] Copy `Entities/ApplicationUser.cs`
- [ ] Copy `Enums/Grade.cs`

### Validation
- [ ]  Verify all entity relationships
- [ ]  Check navigation properties
- [ ]  Validate data annotations

---

##  Phase 3: DbContext Migration

### ApplicationContext.cs
- [ ] Copy and update `DbContexts/ApplicationContext.cs`
- [ ] Update `OnModelCreating` method
- [ ] Remove `OperatingSystem.IsMacOs()` checks if no longer needed
- [ ]  **Validation:** Build project without errors

### SecureApplicationContext.cs
- [ ] Copy and update `DbContexts/SecureApplicationContext.cs`
- [ ] Verify Identity configuration
- [ ] Update schema configuration
- [ ]  **Validation:** Build project without errors

### WebContext.cs
- [ ] Copy and update `DbContexts/WebContext.cs`
- [ ] Combine ApplicationContext + SecureApplicationContext functionality
- [ ] Update `OnModelCreating` method
- [ ]  **Validation:** Build project without errors

### ApiContext.cs
- [ ] Copy and update `DbContexts/ApiContext.cs`
- [ ] Update schema configuration
- [ ]  **Validation:** Build project without errors

### DbContextConfig.cs
- [ ] Copy and update `DbContexts/DbContextConfig.cs`
- [ ] Update `ApplicationContextConfig` method
- [ ] Update `SecureApplicationContextConfig` method
- [ ]  **Validation:** Build project without errors

---

##  Phase 4: Repository Pattern Migration

### IRepository Interface
- [ ] Copy `Interfaces/IRepository.cs`
- [ ] **UPDATE:** Change `ExecuteSqlCommandAsync` to `ExecuteSqlRawAsync`
  ```csharp
  // OLD: Task<int> ExecuteSqlCommandAsync(string queryString);
  // NEW: Task<int> ExecuteSqlRawAsync(string sql, params object[] parameters);
  ```
- [ ]  **Validation:** Interface compiles

### Repository Implementation
- [ ] Copy `Repositories/Repository.cs`
- [ ] **UPDATE:** Fix `ExecuteSqlCommandAsync`  `ExecuteSqlRawAsync`
  ```csharp
  // OLD: return await context.Database.ExecuteSqlCommandAsync(queryString);
  // NEW: return await context.Database.ExecuteSqlRawAsync(sql, parameters);
  ```
- [ ]  **Validation:** Repository compiles
- [ ]  **Testing:** Unit tests pass

---

##  Phase 5: Unit of Work Pattern

- [ ] Copy `UnitOfWork.cs`
- [ ] Verify generic type constraints
- [ ] Update repository initialization
- [ ]  **Validation:** UnitOfWork compiles

---

##  Phase 6: Service Collection Extensions

### ServiceCollectionExtensions.cs Migration
- [ ] Copy `ServiceCollectionExtensions.cs`
- [ ] **CRITICAL UPDATE:** Replace `IHostingEnvironment` with `IWebHostEnvironment`
  ```csharp
  // OLD: IHostingEnvironment env
  // NEW: IWebHostEnvironment env
  ```
- [ ] Update DbContext registration for .NET 9.0
- [ ] Update connection string handling
- [ ] Add Azure SQL optimizations:
  - [ ] Connection resiliency
  - [ ] Retry policies
  - [ ] Command timeout configuration

### Example Updated Code:
```csharp
public static IServiceCollection AddCustomizedContext(
    this IServiceCollection services, 
    IConfiguration configuration, 
    IWebHostEnvironment env) // UPDATED
{
    if (env.IsDevelopment() || env.EnvironmentName == "Testing")
    {
        services.AddDbContext<ApplicationContext>(options =>
            options.UseInMemoryDatabase("TestDb"));
    }
    else
    {
        services.AddDbContext<ApplicationContext>(options =>
            options.UseSqlServer(
                configuration.GetConnectionString("DefaultConnection"),
                sqlOptions =>
                {
                    sqlOptions.MigrationsHistoryTable("Migration", "Contoso");
                    sqlOptions.EnableRetryOnFailure(
                        maxRetryCount: 5,
                        maxRetryDelay: TimeSpan.FromSeconds(30),
                        errorNumbersToAdd: null);
                }));
    }
    // ... rest of configuration
}
```

- [ ]  **Validation:** Build without errors
- [ ]  **Testing:** DI container resolves correctly

---

##  Phase 7: Message Services

### Email Service (SendGrid)
- [ ] Copy `MessageServices.cs`
- [ ] Copy `IEmailSender.cs`
- [ ] Copy `AuthMessageSenderOptions.cs`
- [ ] Update SendGrid package usage
- [ ]  **Validation:** Compiles without errors

### SMS Service (Twilio)
- [ ] Copy `ISmsSender.cs`
- [ ] Copy `SMSOptions.cs`
- [ ] Update Twilio package usage
- [ ]  **Validation:** Compiles without errors

---

##  Phase 8: DTOs and AutoMapper

- [ ] Copy all DTO files from `DTO/` folder
- [ ] Copy AutoMapper profile configurations
- [ ] Update AutoMapper to v13.0+
- [ ]  **Validation:** AutoMapper profiles register correctly

---

##  Phase 9: Validation & Testing

### Build Validation
- [ ]  ContosoUniversity.Data builds without errors
- [ ]  ContosoUniversity.Common builds without errors
- [ ]  No deprecated API warnings

### Runtime Validation
- [ ]  DbContext creation successful
- [ ]  Repository instantiation works
- [ ]  UnitOfWork pattern functional
- [ ]  DI container resolves all services

### Code Quality
- [ ]  No compiler warnings
- [ ]  Code analysis passes
- [ ]  Nullable reference types handled

---

##  Known Breaking Changes & Fixes

| Issue | Old Code | New Code |
|-------|----------|----------|
| **ExecuteSqlCommandAsync** | `context.Database.ExecuteSqlCommandAsync(sql)` | `context.Database.ExecuteSqlRawAsync(sql, parameters)` |
| **IHostingEnvironment** | `IHostingEnvironment env` | `IWebHostEnvironment env` |
| **EF Core Warnings** | Implicit client evaluation | Explicit `.ToList()` or `.AsEnumerable()` |

---

##  Notes
- Keep original migration history files for database compatibility
- Test with both SQL Server and InMemory databases
- Verify Azure SQL connection string format
- Document any schema changes

---

**Dependencies:** None (Foundation layer)  
**Blocks:** All other modules depend on this  
**Next Step:** Once complete, proceed to Web/API/SPA migration
