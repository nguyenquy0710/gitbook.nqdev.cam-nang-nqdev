---
description: 'Nguồn: viblo.asia'
---

# Một số cách tối ưu code và performance CSharp

## **Mở đầu**

Trong bài viết này, chúng ta sẽ tìm hiểu một số mẹo và thủ thuật C# hữu ích về cách cải thiện chất lượng và hiệu suất khi viết code.

Đầu tiên, chúng ta sẽ tìm hiểu cách cải thiện chất lượng code của mình bằng một số mẹo liên quan đến khả năng đọc và giảm reducing nesting code.

Sau đó, chúng ta sẽ thấy một số lưu ý khi nói đến việc xử lý ngoại lệ mà chúng ta cần lưu ý. Khi code chúng ta rất hay bắt gặp các trường hợp

* Guarding against null values: Kiểm tra các giá trị null
* If-else statements: Lệnh if-else
* Exception handling: Bắt exception

### **Cách kiểm tra null**

Khá chắc rằng trong bất kỳ dự án lớn nhỏ nào chúng ta đều có đoạn check null. Nếu object return null thì exception NullReferenceException được throw. Bình thường chúng ta sẽ viết

```csharp
    var product = GetProduct();
    if (product == null)
    {
        // Do something if the object is null.
    }
```

Một cách check null khá hay và hiệu với is và is not quả ở C#

```csharp
    var product = GetProduct();
    if (product is not null)
    {
        // Do something if the object is not null.
    }
```

### **Tối ưu code với if- else**

```csharp
    Product PurchaseProduct(int id)
    {
        var product = GetProduct(id);
        if (product.Quantity > 0)
        {
            product.Quantity--;
            return product;
        }
        else
        {
            SendOutOfStockNotification(product);
            return null;
        }
    }
```

Khá loằng ngoằng. Ở đây chúng ta có thể xóa hẳn câu lệnh else ở dưới đi

```csharp
    Product PurchaseProduct(int id)
    {
        var product = GetProduct(id);
        if (product.Quantity > 0)
        {
            product.Quantity--;
            return product;
        }
        SendOutOfStockNotification(product);
        return null;
    }
```

Nhìn có vẻ clear hơn nhưng nếu product null thì sao nhỉ. Bình thường thì chúng ta sẽ viết code như thế này

```csharp
    bool IsProductInStock(int id)
    {
        var product = GetProduct(id);
        if (product is not null)
        {
            if (product.Quantity > 0)
            {
                return true;
            }
        }
        return false;
    }
```

Ở đây chúng ta thấy có 2 cái if lồng nhau. Để đảm bảo [early return principle](https://medium.com/swlh/return-early-pattern-3d18a41bba8) thì chúng ta nên viết

```csharp
    bool IsProductInStock(int id)
    {
        var product = GetProduct(id);
        if (product is null)
        {
            return false;
        }
        if (product.Quantity <= 0)
        {
            return false;
        }
        return true;
    }
```

Gọn hơn một chút thì chúng ta nên gộp 2 câu if kia vào thành 1

```csharp
    bool IsProductInStock(int id)
    {
        var product = GetProduct(id);
        if (product is null || product.Quantity <= 0)
        {
            return false;
        }
        return true;
    }
```

### **Sử dụng using**

Câu lệnh using đảm bảo rằng Dispose (hoặc DisposeAsync) được gọi ngay cả khi một ngoại lệ xảy ra trong khối using. Tìm hiểu thêm về [using](https://docs.microsoft.com/en-us/dotnet/csharp/language-reference/keywords/using-statement)

Một cách bình thường nhất khi chúng ta sử dụng using

```csharp
    using (var streamReader = new StreamReader("..."))
    {
        string content = streamReader.ReadToEnd();
    }
```

* Ở C# thì chúng ta có thể bỏ luôn dấu ngoặc kép sau using nhưng thế này

```csharp
    using var streamReader = new StreamReader("...");
    string content = streamReader.ReadToEnd();
```

### **Tối ưu cách đọc một Logical Expression**

Ví dụ chúng ta có một hàm để check xem ký tự truyền vào có phải một chữ cái hay không

```csharp
    bool IsLetter(char ch) => (ch >= 'a' && ch <= 'z') || (ch >= 'A' && ch <= 'Z');
```

Ở C# thì chúng ta có một cách viết đơn giản hơn. Chúng ta không cần truyền nhiều lần param `ch` vào nữa

```csharp
    bool IsLetter(char ch) => ch is (>= 'a' and <= 'z') or (>= 'A' and <= 'Z');
```

### **Xóa if-else khi check bool values**

Cách viết bình thường

```csharp
    bool IsInStock(Product product)
    {
        if (product.Quantity > 0)
        {
            return true;
        }
        else
        {
            return false;
        }
    }
```

Đơn giản hơn

```csharp
    bool IsInStock(Product product)
    {
        return product.Quantity > 0;
    }
```

hoặc

```csharp
    bool IsInStock(Product product) => product.Quantity > 0;
```

### **Với switch case thì sao**

Ví dụ chúng ta có một đoạn switch check xem hôm nay có phải ngày cuối tuần hay không.

```csharp
    switch (DateTime.Now.DayOfWeek)
    {
        case DayOfWeek.Monday:
            return "Not Weekend";
        case DayOfWeek.Tuesday:
            return "Not Weekend";
        case DayOfWeek.Wednesday:
            return "Not Weekend";
        case DayOfWeek.Thursday:
            return "Not Weekend";
        case DayOfWeek.Friday:
            return "Not Weekend";
        case DayOfWeek.Saturday:
            return "Weekend";
        case DayOfWeek.Sunday:
            return "Weekend";
        default:
            throw new ArgumentOutOfRangeException();
    }
```

Hoàn toàn có thể viết ngắn gọn lại

```csharp
    switch (DateTime.Now.DayOfWeek)
    {
        case DayOfWeek.Monday:
        case DayOfWeek.Tuesday:
        case DayOfWeek.Wednesday:
        case DayOfWeek.Thursday:
        case DayOfWeek.Friday:
            return "Not Weekend";
        case DayOfWeek.Saturday:
        case DayOfWeek.Sunday:
            return "Weekend";
        default:
            throw new ArgumentOutOfRangeException();
    }
```

hoặc với C#

```csharp
    DateTime.Now.DayOfWeek switch
    {
        DayOfWeek.Monday => "Not Weekend",
        DayOfWeek.Tuesday => "Not Weekend",
        DayOfWeek.Wednesday => "Not Weekend",
        DayOfWeek.Thursday => "Not Weekend",
        DayOfWeek.Friday => "Not Weekend",
        DayOfWeek.Saturday => "Weekend",
        DayOfWeek.Sunday  => "Weekend",
        _ => throw new ArgumentOutOfRangeException()
    }
```

với C#

```csharp
    DateTime.Now.DayOfWeek switch
    {
        DayOfWeek.Monday or DayOfWeek.Tuesday or DayOfWeek.Wednesday or DayOfWeek.Thursday or DayOfWeek.Friday => "Not Weekend",
        DayOfWeek.Saturday or DayOfWeek.Sunday => "Weekend",
        _ => throw new ArgumentOutOfRangeException()
    }
```

dùng not trong C#

```csharp
    DateTime.Now.DayOfWeek switch
    {
        not (DayOfWeek.Saturday or DayOfWeek.Sunday) => "Not Weekend",
        DayOfWeek.Saturday or DayOfWeek.Sunday => "Weekend",
        _ => throw new ArgumentOutOfRangeException()
    }
```

### **Cách tối hơn khi filter exception**

Ví dụ chúng ta có một đoạn filter exception 400 bad request với 404 not found

```csharp
    try
    {
        await GetBlogsFromApi();
    }
    catch (HttpRequestException e)
    {
        if (e.StatusCode == HttpStatusCode.BadRequest)
        {
            HandleBadRequest(e);
        }
        else if (e.StatusCode == HttpStatusCode.NotFound)
        {
            HandleNotFound(e);
        }
    }
```

đơn giản và clear hơn khi dùng với `when`

```csharp
    try
    {
        await GetBlogsFromApi();
    }
    catch (HttpRequestException e) when (e.StatusCode == HttpStatusCode.BadRequest)
    {
        HandleBadRequest(e);
    }
    catch (HttpRequestException e) when (e.StatusCode == HttpStatusCode.NotFound)
    {
        HandleNotFound(e);
    }
```

## **Tóm lại**

Ở đây mình tổng hợp một số trick thường được dùng hoặc là mình hay dùng để tối ưu code. Cho dòng code ngắn gọn dễ hiểu và performance tốt hơn trong C#.

Cảm ơn các bạn đã theo dõi
