# Phân tích các phương pháp Caching dữ liệu trong .NET Core và .NET Framework

Trong một dự án .NET, caching là một kỹ thuật quan trọng giúp cải thiện hiệu suất và giảm tải cho hệ thống bằng cách lưu trữ tạm thời dữ liệu để tránh truy vấn lặp lại từ nguồn gốc (database, API bên ngoài, hoặc file system).

Bài viết này sẽ phân tích các phương pháp caching phổ biến trong [**.NET Core**](https://github.com/nguyenquy0710/gitbook.nqdev.cam-nang-nqdev/blob/main/cong-nghe/languages-and-frameworks/dotnet/asp.net-core) và **.NET Framework**, đồng thời so sánh điểm mạnh và hạn chế của từng phương pháp.

***

## **1. Các Loại Caching Phổ Biến**

Trong .NET, caching có thể chia thành các loại chính sau:

* **In-Memory Caching**: Lưu trữ dữ liệu trong bộ nhớ RAM của ứng dụng.
* **Distributed Caching**: Dữ liệu được lưu trữ trên một hệ thống cache bên ngoài, chẳng hạn như Redis hoặc SQL Server.
* **Response Caching**: Dùng để cache HTTP response trong các ứng dụng web.
* **Output Caching (chỉ có trong .NET Framework)**: Cache toàn bộ hoặc một phần kết quả của các action trong ASP.NET MVC/WebForms.

***

## **2. In-Memory Caching**

### **🔹 Cách Hoạt Động**

* Lưu trữ dữ liệu ngay trong bộ nhớ RAM của ứng dụng, giúp truy xuất nhanh chóng.
* Phù hợp với các ứng dụng có khối lượng dữ liệu nhỏ hoặc không cần chia sẻ cache giữa nhiều server.

### **🔹 Cách Triển Khai**

#### **Trong .NET Core**

.NET Core cung cấp `IMemoryCache` để lưu trữ dữ liệu trong bộ nhớ:

```csharp
using Microsoft.Extensions.Caching.Memory;

public class ProductService
{
    private readonly IMemoryCache _cache;

    public ProductService(IMemoryCache cache)
    {
        _cache = cache;
    }

    public Product GetProduct(int id)
    {
        string cacheKey = $"product_{id}";

        if (!_cache.TryGetValue(cacheKey, out Product product))
        {
            // Giả lập lấy dữ liệu từ database
            product = GetProductFromDatabase(id);

            // Cấu hình cache với thời gian hết hạn
            var cacheOptions = new MemoryCacheEntryOptions()
                .SetSlidingExpiration(TimeSpan.FromMinutes(5));

            _cache.Set(cacheKey, product, cacheOptions);
        }

        return product;
    }
}
```

#### **Trong .NET Framework**

Dùng `MemoryCache` từ `System.Runtime.Caching`:

```csharp
using System;
using System.Runtime.Caching;

public class ProductService
{
    private static MemoryCache _cache = MemoryCache.Default;

    public Product GetProduct(int id)
    {
        string cacheKey = $"product_{id}";

        if (_cache.Contains(cacheKey))
        {
            return (Product)_cache.Get(cacheKey);
        }

        Product product = GetProductFromDatabase(id);
        _cache.Set(cacheKey, product, DateTimeOffset.Now.AddMinutes(5));

        return product;
    }
}
```

### **🔹 Ưu và Nhược Điểm**

| **Ưu điểm**                                               | **Nhược điểm**                                                                      |
| --------------------------------------------------------- | ----------------------------------------------------------------------------------- |
| Truy xuất dữ liệu nhanh vì lưu trữ trong RAM.             | Không phù hợp cho hệ thống phân tán, vì cache không được chia sẻ giữa nhiều server. |
| Dễ triển khai, không cần phụ thuộc vào dịch vụ bên ngoài. | Cần quản lý bộ nhớ cẩn thận để tránh làm đầy RAM.                                   |

***

## **3. Distributed Caching (Redis, SQL Server, NCache, v.v.)**

### **🔹 Cách Hoạt Động**

* Cache được lưu trên hệ thống bên ngoài, có thể chia sẻ giữa nhiều server.
* Phù hợp cho các ứng dụng microservices hoặc hệ thống có nhiều node backend.

### **🔹 Cách Triển Khai Redis Cache**

#### **Trong .NET Core**

.NET Core hỗ trợ Redis thông qua `IDistributedCache`:

```csharp
using Microsoft.Extensions.Caching.Distributed;
using System.Text.Json;
using System.Text;

public class ProductService
{
    private readonly IDistributedCache _cache;

    public ProductService(IDistributedCache cache)
    {
        _cache = cache;
    }

    public async Task<Product> GetProductAsync(int id)
    {
        string cacheKey = $"product_{id}";
        string cachedData = await _cache.GetStringAsync(cacheKey);

        if (!string.IsNullOrEmpty(cachedData))
        {
            return JsonSerializer.Deserialize<Product>(cachedData);
        }

        Product product = GetProductFromDatabase(id);
        string serializedData = JsonSerializer.Serialize(product);

        await _cache.SetStringAsync(cacheKey, serializedData, new DistributedCacheEntryOptions
        {
            AbsoluteExpirationRelativeToNow = TimeSpan.FromMinutes(10)
        });

        return product;
    }
}
```

#### **Trong .NET Framework**

.NET Framework không hỗ trợ `IDistributedCache`, nhưng có thể sử dụng **StackExchange.Redis**:

```csharp
using StackExchange.Redis;

public class RedisCacheService
{
    private readonly ConnectionMultiplexer _redis = ConnectionMultiplexer.Connect("localhost");

    public void SetCache(string key, string value)
    {
        var db = _redis.GetDatabase();
        db.StringSet(key, value, TimeSpan.FromMinutes(10));
    }

    public string GetCache(string key)
    {
        var db = _redis.GetDatabase();
        return db.StringGet(key);
    }
}
```

### **🔹 Ưu và Nhược Điểm**

| **Ưu điểm**                                                            | **Nhược điểm**                                                      |
| ---------------------------------------------------------------------- | ------------------------------------------------------------------- |
| Có thể chia sẻ cache giữa nhiều server, phù hợp cho hệ thống phân tán. | Phải cài đặt Redis hoặc SQL Server để sử dụng.                      |
| Hỗ trợ dung lượng cache lớn, không giới hạn bởi RAM của ứng dụng.      | Độ trễ cao hơn so với in-memory cache do cần truy xuất qua network. |

***

## **4. Response Caching trong .NET Core**

### **🔹 Cách Hoạt Động**

Dùng để cache phản hồi HTTP response, giúp giảm tải cho API.

```csharp
app.UseResponseCaching();
```

Khi sử dụng trong Controller:

```csharp
[ResponseCache(Duration = 60, Location = ResponseCacheLocation.Client)]
public IActionResult GetData()
{
    return Ok("Dữ liệu được cache trong 60 giây");
}
```

### **🔹 Ưu và Nhược Điểm**

| **Ưu điểm**                                               | **Nhược điểm**                                         |
| --------------------------------------------------------- | ------------------------------------------------------ |
| Giảm tải API bằng cách lưu cache trực tiếp phản hồi HTTP. | Không phù hợp cho dữ liệu động hoặc có authentication. |

***

## **5. Output Caching (Chỉ có trong .NET Framework)**

Dùng để cache kết quả của action trong ASP.NET MVC/WebForms:

```csharp
[OutputCache(Duration = 60, VaryByParam = "id")]
public ActionResult GetProduct(int id)
{
    return View();
}
```

Tuy nhiên, trong .NET Core, tính năng này đã bị loại bỏ và thay thế bằng **Response Caching**.

***

## **Kết Luận**

| Loại Cache                                                                                                                                                                              | Phù hợp với                | Không phù hợp với                    |
| --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------- | ------------------------------------ |
| [**In-Memory Cache**](phan-tich-cac-phuong-phap-caching-du-lieu-trong-.net-core-va-.net-framework.md#id-2.-in-memory-caching)                                                           | Ứng dụng nhỏ, đơn server   | Hệ thống phân tán                    |
| [**Distributed Cache (Redis, SQL Server, v.v.)**](phan-tich-cac-phuong-phap-caching-du-lieu-trong-.net-core-va-.net-framework.md#id-3.-distributed-caching-redis-sql-server-ncache-v.v) | Ứng dụng lớn, nhiều server | Ứng dụng nhỏ, không có nhiều traffic |
| [**Response Caching**](phan-tich-cac-phuong-phap-caching-du-lieu-trong-.net-core-va-.net-framework.md#id-4.-response-caching-trong-.net-core)                                           | API có response tĩnh       | API có dữ liệu động                  |

Mỗi loại caching có ưu và nhược điểm riêng, tùy vào đặc thù của hệ thống mà lựa chọn giải pháp phù hợp nhất! 🚀
