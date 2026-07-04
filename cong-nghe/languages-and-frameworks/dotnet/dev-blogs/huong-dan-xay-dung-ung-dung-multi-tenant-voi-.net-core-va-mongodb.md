# Hướng dẫn xây dựng ứng dụng multi-tenant với .NET Core và MongoDB

## **1. Tổng quan về multi-tenancy**

Multi-tenancy là kiến trúc trong đó một ứng dụng duy nhất phục vụ nhiều khách hàng (tenants), mỗi tenant có dữ liệu và cấu hình độc lập. Trong trường hợp sử dụng MongoDB, có thể cấu hình để mỗi tenant sử dụng một cơ sở dữ liệu riêng biệt.

## **2. Các thách thức**

* **Quản lý kết nối:** Xử lý việc kết nối đến các cơ sở dữ liệu khác nhau dựa trên tenant hiện tại.
* **Tách biệt dữ liệu:** Đảm bảo dữ liệu của các tenants được lưu trữ và truy xuất chính xác.
* **Hiệu suất và bảo mật:** Hạn chế việc rò rỉ dữ liệu giữa các tenants và tối ưu hóa tài nguyên.

## **3. Tạo MongoDB Context Factory**

Để xây dựng ứng dụng multi-tenant với MongoDB, bạn có thể triển khai một MongoDB Context Factory để tạo kết nối cho từng tenant.

### **Bước triển khai MongoDB Context Factory**

**B1. Cài đặt các gói NuGet:**

```bash
dotnet add package MongoDB.Driver
```

**B2. Định nghĩa `TenantConfiguration`** Mỗi tenant sẽ có cấu hình riêng, bao gồm connection string và database name.

```csharp
public class TenantConfiguration
{
    public string TenantId { get; set; }
    public string ConnectionString { get; set; }
    public string DatabaseName { get; set; }
}
```

**B3. Quản lý danh sách tenants** Bạn có thể lưu danh sách cấu hình tenants trong tệp cấu hình (appsettings.json) hoặc cơ sở dữ liệu.

Ví dụ:

```json
"Tenants": [
    {
        "TenantId": "tenant1",
        "ConnectionString": "mongodb://localhost:27017",
        "DatabaseName": "tenant1_db"
    },
    {
        "TenantId": "tenant2",
        "ConnectionString": "mongodb://localhost:27017",
        "DatabaseName": "tenant2_db"
    }
]
```

**B4. Tạo MongoDB Context**

```csharp
public class MongoDbContext
{
    private readonly IMongoDatabase _database;

    public MongoDbContext(string connectionString, string databaseName)
    {
        var client = new MongoClient(connectionString);
        _database = client.GetDatabase(databaseName);
    }

    public IMongoCollection<T> GetCollection<T>(string collectionName)
    {
        return _database.GetCollection<T>(collectionName);
    }
}
```

**B5. Triển khai MongoDbContextFactory**

```csharp
public class MongoDbContextFactory
{
    private readonly IEnumerable<TenantConfiguration> _tenantConfigurations;

    public MongoDbContextFactory(IConfiguration configuration)
    {
        _tenantConfigurations = configuration.GetSection("Tenants").Get<List<TenantConfiguration>>();
    }

    public MongoDbContext CreateContext(string tenantId)
    {
        var tenantConfig = _tenantConfigurations.FirstOrDefault(t => t.TenantId == tenantId);
        if (tenantConfig == null)
        {
            throw new Exception($"Tenant with ID {tenantId} not found.");
        }

        return new MongoDbContext(tenantConfig.ConnectionString, tenantConfig.DatabaseName);
    }
}
```

**B6. Middleware để xác định tenant hiện tại** Middleware giúp xác định tenant từ yêu cầu HTTP (ví dụ: từ header hoặc subdomain).

```csharp
public class TenantMiddleware
{
    private readonly RequestDelegate _next;

    public TenantMiddleware(RequestDelegate next)
    {
        _next = next;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        if (context.Request.Headers.TryGetValue("X-Tenant-ID", out var tenantId))
        {
            context.Items["TenantId"] = tenantId.ToString();
        }

        await _next(context);
    }
}
```

**B7. Đăng ký dịch vụ và Middleware** Trong `Startup.cs` hoặc `Program.cs`:

```csharp
public void ConfigureServices(IServiceCollection services)
{
    services.AddSingleton<MongoDbContextFactory>();
    services.AddScoped(provider =>
    {
        var httpContext = provider.GetRequiredService<IHttpContextAccessor>().HttpContext;
        var tenantId = httpContext.Items["TenantId"]?.ToString();
        var factory = provider.GetRequiredService<MongoDbContextFactory>();
        return factory.CreateContext(tenantId);
    });

    services.AddHttpContextAccessor();
}

public void Configure(IApplicationBuilder app)
{
    app.UseMiddleware<TenantMiddleware>();
}
```

## **4. Sử dụng trong Controller**

Bạn có thể inject `MongoDbContext` để thao tác với cơ sở dữ liệu tương ứng.

```csharp
[ApiController]
[Route("api/[controller]")]
public class SampleController : ControllerBase
{
    private readonly MongoDbContext _dbContext;

    public SampleController(MongoDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    [HttpGet("data")]
    public IActionResult GetData()
    {
        var collection = _dbContext.GetCollection<MyEntity>("MyCollection");
        var data = collection.Find(FilterDefinition<MyEntity>.Empty).ToList();
        return Ok(data);
    }
}
```

## **5. Kết luận**

Triển khai multi-tenancy với .NET Core và MongoDB không quá phức tạp khi sử dụng một kiến trúc hợp lý. Với MongoDB Context Factory và Middleware, bạn có thể dễ dàng quản lý các kết nối đến cơ sở dữ liệu riêng của từng tenant. Cách tiếp cận này đảm bảo tính mở rộng và tách biệt dữ liệu cho ứng dụng.
