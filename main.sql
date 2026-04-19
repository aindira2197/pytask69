CREATE TABLE http_requests (
    id SERIAL PRIMARY KEY,
    method VARCHAR(10),
    path VARCHAR(255),
    query_params JSONB,
    headers JSONB,
    body TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE http_response (
    id SERIAL PRIMARY KEY,
    request_id INTEGER,
    status_code INTEGER,
    reason_phrase VARCHAR(50),
    headers JSONB,
    body TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (request_id) REFERENCES http_requests (id)
);

CREATE INDEX idx_http_requests_path ON http_requests (path);
CREATE INDEX idx_http_requests_method ON http_requests (method);
CREATE INDEX idx_http_response_status_code ON http_response (status_code);

INSERT INTO http_requests (method, path, query_params, headers, body)
VALUES ('GET', '/users', '{"id": 1}', '{"Content-Type": "application/json"}', '');

INSERT INTO http_response (request_id, status_code, reason_phrase, headers, body)
VALUES (1, 200, 'OK', '{"Content-Type": "application/json"}', '[{"id": 1, "name": "John Doe"}]');

CREATE OR REPLACE FUNCTION parse_http_request(p_method VARCHAR, p_path VARCHAR, p_query_params JSONB, p_headers JSONB, p_body TEXT)
RETURNS INTEGER AS $$
DECLARE
    v_request_id INTEGER;
BEGIN
    INSERT INTO http_requests (method, path, query_params, headers, body)
    VALUES (p_method, p_path, p_query_params, p_headers, p_body)
    RETURNING id INTO v_request_id;
    RETURN v_request_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION send_http_response(p_request_id INTEGER, p_status_code INTEGER, p_reason_phrase VARCHAR, p_headers JSONB, p_body TEXT)
RETURNS VOID AS $$
BEGIN
    INSERT INTO http_response (request_id, status_code, reason_phrase, headers, body)
    VALUES (p_request_id, p_status_code, p_reason_phrase, p_headers, p_body);
END;
$$ LANGUAGE plpgsql;

SELECT parse_http_request('GET', '/users', '{"id": 1}', '{"Content-Type": "application/json"}', '');
SELECT send_http_response(1, 200, 'OK', '{"Content-Type": "application/json"}', '[{"id": 1, "name": "John Doe"}]');

CREATE OR REPLACE FUNCTION handle_http_request(p_method VARCHAR, p_path VARCHAR, p_query_params JSONB, p_headers JSONB, p_body TEXT)
RETURNS JSONB AS $$
DECLARE
    v_request_id INTEGER;
    v_response JSONB;
BEGIN
    v_request_id := parse_http_request(p_method, p_path, p_query_params, p_headers, p_body);
    send_http_response(v_request_id, 200, 'OK', '{"Content-Type": "application/json"}', '[{"id": 1, "name": "John Doe"}]');
    SELECT json_build_object('status_code', 200, 'reason_phrase', 'OK', 'body', '[{"id": 1, "name": "John Doe"}]') INTO v_response;
    RETURN v_response;
END;
$$ LANGUAGE plpgsql;

SELECT handle_http_request('GET', '/users', '{"id": 1}', '{"Content-Type": "application/json"}', '');