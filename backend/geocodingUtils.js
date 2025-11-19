const axios = require('axios');

/**
 * Geocode address to coordinates using OpenStreetMap Nominatim (free)
 * @param {string} address - Full address or city, state, country
 * @returns {Promise<{lat: number, lon: number, city: string, state: string, country: string}>}
 */
async function geocodeAddress(address) {
  try {
    const url = `https://nominatim.openstreetmap.org/search?format=json&q=${encodeURIComponent(address)}&limit=1`;

    const response = await axios.get(url, {
      headers: {
        'User-Agent': 'Zaryah-Education-Platform/1.0',
      },
      timeout: 5000,
    });

    if (response.data && response.data.length > 0) {
      const result = response.data[0];

      // Parse display name to extract location components
      const parts = result.display_name.split(',').map(p => p.trim());

      return {
        latitude: parseFloat(result.lat),
        longitude: parseFloat(result.lon),
        city: result.address?.city || result.address?.town || result.address?.village || parts[0],
        state: result.address?.state || result.address?.province || parts[parts.length - 3] || '',
        country: result.address?.country || parts[parts.length - 1] || '',
        formattedAddress: result.display_name,
      };
    }

    return null;
  } catch (error) {
    console.error('Geocoding error:', error.message);
    return null;
  }
}

/**
 * Reverse geocode coordinates to address
 * @param {number} lat - Latitude
 * @param {number} lon - Longitude
 * @returns {Promise<{city: string, state: string, country: string}>}
 */
async function reverseGeocode(lat, lon) {
  try {
    const url = `https://nominatim.openstreetmap.org/reverse?format=json&lat=${lat}&lon=${lon}`;

    const response = await axios.get(url, {
      headers: {
        'User-Agent': 'Zaryah-Education-Platform/1.0',
      },
      timeout: 5000,
    });

    if (response.data && response.data.address) {
      const addr = response.data.address;

      return {
        city: addr.city || addr.town || addr.village || '',
        state: addr.state || addr.province || '',
        country: addr.country || '',
        formattedAddress: response.data.display_name,
      };
    }

    return null;
  } catch (error) {
    console.error('Reverse geocoding error:', error.message);
    return null;
  }
}

module.exports = {
  geocodeAddress,
  reverseGeocode,
};
