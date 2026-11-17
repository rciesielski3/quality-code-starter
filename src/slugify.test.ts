import { describe, expect, it } from 'vitest';

import { slugify } from './slugify.js';

describe('slugify', () => {
  it('lowercases the input', () => {
    expect(slugify('Hello')).toBe('hello');
  });

  it('collapses repeated separators into one hyphen', () => {
    expect(slugify('a   b__c--d')).toBe('a-b-c-d');
  });

  it('trims leading and trailing separators', () => {
    expect(slugify('  --Hello world!--  ')).toBe('hello-world');
  });

  it('strips diacritics from accented letters', () => {
    expect(slugify('Crème brûlée à la façon')).toBe('creme-brulee-a-la-facon');
  });

  it('keeps digits', () => {
    expect(slugify('Route 66')).toBe('route-66');
  });

  it('returns an empty string when no alphanumerics remain', () => {
    expect(slugify('!!!')).toBe('');
  });
});
