/** @type {import('next').NextConfig} */
const nextConfig = {
  images: {
    remotePatterns: [
      { protocol: "https", hostname: "**" },
      { protocol: "http", hostname: "**" },
    ],
  },
  env: {
    SERVER_API_URL: process.env.SERVER_API_URL,
  },
  webpack(config) {
    config.cache = {
      type: "filesystem",
      compression: "gzip",
      allowCollectingMemory: true,
    };
    config.module.rules.push({
      test: /\.(png|jpg|gif|svg|woff|woff2|json)$/,
      type: "asset/resource",
      generator: {
        emit: true,
      },
    });
    return config;
  },
};

module.exports = nextConfig;
