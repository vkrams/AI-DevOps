const request = require('supertest');
const app = require('../index');

describe('GET /users', () => {
  it('should return status 200', async () => {
    const response = await request(app).get('/users');
    expect(response.status).toBe(200);
  });

  it('should return a list of users', async () => {
    const response = await request(app).get('/users');
    expect(Array.isArray(response.body.users)).toBe(true);
    expect(response.body.users.length).toBeGreaterThan(0);
    expect(response.body.count).toBe(response.body.users.length);
  });

  it('should return users with id, name, and email fields', async () => {
    const response = await request(app).get('/users');
    response.body.users.forEach((user) => {
      expect(user).toHaveProperty('id');
      expect(user).toHaveProperty('name');
      expect(user).toHaveProperty('email');
    });
  });
});
