class HttpRequest:
    def __init__(self, method, path, http_version, headers, body):
        self.method = method
        self.path = path
        self.http_version = http_version
        self.headers = headers
        self.body = body

    def __str__(self):
        return f"{self.method} {self.path} {self.http_version}"

class HttpResponse:
    def __init__(self, http_version, status_code, reason, headers, body):
        self.http_version = http_version
        self.status_code = status_code
        self.reason = reason
        self.headers = headers
        self.body = body

    def __str__(self):
        return f"{self.http_version} {self.status_code} {self.reason}"

def parse_http_request(data):
    lines = data.splitlines()
    method, path, http_version = lines[0].split()
    headers = {}
    body = ""
    i = 1
    while i < len(lines):
        if lines[i] == "":
            body = "\n".join(lines[i+1:])
            break
        key, value = lines[i].split(": ", 1)
        headers[key] = value
        i += 1
    return HttpRequest(method, path, http_version, headers, body)

def create_http_response(http_version, status_code, reason, headers, body):
    return HttpResponse(http_version, status_code, reason, headers, body)

def handle_request(request):
    if request.method == "GET":
        return create_http_response(request.http_version, 200, "OK", {"Content-Type": "text/plain"}, "Hello, World!")
    else:
        return create_http_response(request.http_version, 405, "Method Not Allowed", {"Content-Type": "text/plain"}, "")

def http_server_handle(data):
    request = parse_http_request(data)
    response = handle_request(request)
    return f"{response.http_version} {response.status_code} {response.reason}\r\n" + "\r\n".join(f"{key}: {value}" for key, value in response.headers.items()) + "\r\n\r\n" + response.body

data = "GET / HTTP/1.1\r\nHost: example.com\r\n\r\n"
print(http_server_handle(data))