'use strict';

const request = require('supertest');
const app = require('./index');

describe('GET /health', () => {
  it('returns 200', async () => {
    const res = await request(app).get('/health');
    expect(res.statusCode).toBe(200);
  });

  it('returns correct body', async () => {
    const res = await request(app).get('/health');
    expect(res.body.status).toBe('ok');
    expect(res.body.service).toBe('node-api');
  });
});

describe('GET /api/v1/hello', () => {
  it('returns 200', async () => {
    const res = await request(app).get('/api/v1/hello');
    expect(res.statusCode).toBe(200);
  });

  it('returns correct body', async () => {
    const res = await request(app).get('/api/v1/hello');
    expect(res.body).toHaveProperty('message');
    expect(res.body).toHaveProperty('version');
  });
});
