/**
 * Contact Filtering Utility
 * Blocks emails, social handles, URLs, phone numbers, and contact information
 */

import { getToken } from '../actions/auth';

// Regex patterns for detecting specific contact information only
const CONTACT_PATTERNS = {
  // Email addresses
  email: /[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}/g,
  
  // URLs and links (only actual URLs, not just text with dots)
  url: /(https?:\/\/[^\s]+|www\.[^\s]+|[^\s]+\.[a-z]{2,}(?:\/[^\s]*)?)/gi,
  
  // Phone numbers (various formats)
  phone: /(\+?1[-.\s]?)?\(?([0-9]{3})\)?[-.\s]?([0-9]{3})[-.\s]?([0-9]{4})|(\+?[0-9]{1,3}[-.\s]?)?[0-9]{3,4}[-.\s]?[0-9]{3,4}[-.\s]?[0-9]{3,4}/g,
  
  // Social media handles (only @username format)
  social: /@[a-zA-Z0-9_]+/g,
  
  // State names (US states)
  states: /\b(Alabama|Alaska|Arizona|Arkansas|California|Colorado|Connecticut|Delaware|Florida|Georgia|Hawaii|Idaho|Illinois|Indiana|Iowa|Kansas|Kentucky|Louisiana|Maine|Maryland|Massachusetts|Michigan|Minnesota|Mississippi|Missouri|Montana|Nebraska|Nevada|New Hampshire|New Jersey|New Mexico|New York|North Carolina|North Dakota|Ohio|Oklahoma|Oregon|Pennsylvania|Rhode Island|South Carolina|South Dakota|Tennessee|Texas|Utah|Vermont|Virginia|Washington|West Virginia|Wisconsin|Wyoming)\b/gi,
  
  // Social media platform mentions
  socialPlatforms: /\b(instagram|twitter|facebook|linkedin|tiktok|snapchat|youtube|twitch)\b/gi
};

/**
 * Check if text contains any contact information
 * @param {string} text - Text to check
 * @returns {object} - { hasContact: boolean, violations: array, filteredText: string }
 */
export const checkForContactInfo = (text) => {
  if (!text || typeof text !== 'string') {
    return { hasContact: false, violations: [], filteredText: text };
  }

  const violations = [];
  let filteredText = text;

  // Check for emails
  if (CONTACT_PATTERNS.email.test(text)) {
    violations.push('email');
    filteredText = filteredText.replace(CONTACT_PATTERNS.email, '[EMAIL BLOCKED]');
  }

  // Check for URLs
  if (CONTACT_PATTERNS.url.test(filteredText)) {
    violations.push('url');
    filteredText = filteredText.replace(CONTACT_PATTERNS.url, '[LINK BLOCKED]');
  }

  // Check for phone numbers
  if (CONTACT_PATTERNS.phone.test(filteredText)) {
    violations.push('phone');
    filteredText = filteredText.replace(CONTACT_PATTERNS.phone, '[PHONE BLOCKED]');
  }

  // Check for social media handles
  if (CONTACT_PATTERNS.social.test(filteredText)) {
    violations.push('social');
    filteredText = filteredText.replace(CONTACT_PATTERNS.social, '[HANDLE BLOCKED]');
  }

  // Check for state names
  if (CONTACT_PATTERNS.states.test(filteredText)) {
    violations.push('states');
    filteredText = filteredText.replace(CONTACT_PATTERNS.states, '[STATE BLOCKED]');
  }

  // Check for social platform mentions
  if (CONTACT_PATTERNS.socialPlatforms.test(filteredText)) {
    violations.push('social_platforms');
    filteredText = filteredText.replace(CONTACT_PATTERNS.socialPlatforms, '[PLATFORM BLOCKED]');
  }

  return {
    hasContact: violations.length > 0,
    violations: [...new Set(violations)], // Remove duplicates
    filteredText: filteredText.trim()
  };
};

/**
 * Get user-friendly error message for contact violations
 * @param {array} violations - Array of violation types
 * @returns {string} - Error message
 */
export const getContactErrorMessage = (violations) => {
  if (!violations || violations.length === 0) {
    return '';
  }

  const violationMessages = {
    email: 'email addresses',
    url: 'external links or URLs',
    phone: 'phone numbers',
    social: 'social media handles (@username)',
    states: 'state names',
    social_platforms: 'social media platform mentions'
  };

  const detectedTypes = violations.map(v => violationMessages[v] || v).join(', ');
  
  return `Message blocked: Contains ${detectedTypes}. Please remove contact information and try again.`;
};

/**
 * Validate text for contact information (for form validation)
 * @param {string} text - Text to validate
 * @returns {string|true} - Error message or true if valid
 */
export const validateNoContactInfo = (text) => {
  const result = checkForContactInfo(text);
  
  if (result.hasContact) {
    return getContactErrorMessage(result.violations);
  }
  
  return true;
};

/**
 * Filter message content and return safe version
 * @param {string} message - Original message
 * @returns {object} - { safe: boolean, filteredMessage: string, violations: array }
 */
export const filterMessageContent = (message) => {
  const result = checkForContactInfo(message);
  
  return {
    safe: !result.hasContact,
    filteredMessage: result.filteredText,
    violations: result.violations,
    originalMessage: message
  };
};

/**
 * Get violation count for analytics
 * @param {string} text - Text to analyze
 * @returns {object} - Violation counts by type
 */
export const getViolationStats = (text) => {
  const result = checkForContactInfo(text);
  const stats = {};
  
  result.violations.forEach(violation => {
    stats[violation] = (stats[violation] || 0) + 1;
  });
  
  return stats;
};

/**
 * Track violation on backend
 * @param {array} violations - Array of violation types
 * @param {string} content - Original content that triggered violations
 * @param {string} context - Context where violation occurred (chat, post, etc.)
 * @returns {Promise<object>} - API response
 */
export const trackViolation = async (violations, content, context = 'chat') => {
  try {
    const response = await fetch(`${process.env.SERVER_API_URL}/user/violations/track`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${await getToken()}`,
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      body: JSON.stringify({
        violations,
        content,
        context
      })
    });

    const result = await response.json();
    return result;
  } catch (error) {
    console.error('Failed to track violation:', error);
    return {
      status: 'error',
      message: 'Failed to track violation'
    };
  }
};

/**
 * Get user violation statistics
 * @returns {Promise<object>} - User's violation stats
 */
export const getUserViolationStats = async () => {
  try {
    const response = await fetch(`${process.env.SERVER_API_URL}/user/violations/stats`, {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${await getToken()}`,
        'Accept': 'application/json'
      }
    });

    const result = await response.json();
    return result;
  } catch (error) {
    console.error('Failed to get violation stats:', error);
    return {
      status: 'error',
      message: 'Failed to get violation statistics'
    };
  }
};
