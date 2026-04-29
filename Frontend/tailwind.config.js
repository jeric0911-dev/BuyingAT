/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./src/pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/components/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      fontFamily: {
        publicSans: ["var(--font-publicSans)"],
      },
      colors: {
        teal: "#6ABBB4",
        yellow: "#EBC80C",
        orange: "#FA8232",
        green: "#2DB224",
        lightOrange: "#FFE7D6",
        lightGray: "#F2F4F5",
        border: "#E4E7E9",
        skyBlue: "#32A852",
        skyBlueHover: "#2A8F47",
        redPink: "#EE5858",
        tBlack: "#191C1F",
        tGray: "#77878F",
        icon: "#1F2744"
      },
    },
  },
  plugins: [
    require("@tailwindcss/forms")({
      strategy: "class",
    }),
    require("@tailwindcss/typography"),
  ],
};
