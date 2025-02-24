import { test, expect } from '@playwright/test';

test.describe('Twitter Clone E2E Tests', () => {
  test('should display the home page', async ({ page }) => {
    await page.goto('/');
    await expect(page).toHaveTitle(/Twitter Clone/);
  });

  test('should register a new user', async ({ page }) => {
    await page.goto('/register');
    
    // Fill in registration form
    await page.fill('input[name="email"]', 'test@example.com');
    await page.fill('input[name="username"]', 'testuser');
    await page.fill('input[name="password"]', 'password123');
    
    // Submit form
    await page.click('button[type="submit"]');
    
    // Verify redirect to home page
    await expect(page).toHaveURL('/');
  });

  test('should create and view a tweet', async ({ page }) => {
    await page.goto('/');
    
    // Create tweet
    await page.fill('textarea[name="tweet"]', 'Hello, World!');
    await page.click('button[type="submit"]');
    
    // Verify tweet appears in feed
    await expect(page.locator('text=Hello, World!')).toBeVisible();
  });
}); 