# Classified - A Modern E-commerce Platform

This is a feature-rich, modern e-commerce and classified ads platform built with Next.js and Tailwind CSS. It provides a seamless and intuitive user experience for both buyers and sellers.

## Table of Contents

- [Features](#features)
- [Tech Stack](#tech-stack)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
  - [Running the Development Server](#running-the-development-server)
- [Available Scripts](#available-scripts)
- [Environment Variables](#environment-variables)
- [Deployment](#deployment)
- [Contributing](#contributing)
- [License](#license)

## Features

-   **Product Management:** Add, edit, and manage product listings.
-   **User Authentication:** Secure user login and registration.
-   **Wishlist:** Save favorite items to a wishlist.
-   **Shopping Cart:** A fully functional shopping cart.
-   **Search and Filtering:** Powerful search and filtering capabilities.
-   **Responsive Design:** A mobile-first design that works on all screen sizes.
-   **Real-time Notifications:** Real-time updates with Pusher-JS.
-   **And much more...**

## Tech Stack

-   **Framework:** [Next.js](https://nextjs.org/)
-   **Styling:** [Tailwind CSS](https://tailwindcss.com/)
-   **State Management:** React Hooks
-   **Form Handling:** [React Hook Form](https://react-hook-form.com/)
-   **API Communication:** Fetch API
-   **Real-time:** [Pusher-JS](https://pusher.com/docs/channels/getting_started/javascript)
-   **Linting:** [ESLint](https://eslint.org/)

## Getting Started

Follow these instructions to get a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

You need to have Node.js and npm (or yarn/pnpm/bun) installed on your machine.

-   [Node.js](https://nodejs.org/en/) (v18 or later recommended)
-   [npm](https://www.npmjs.com/get-npm)

### Installation

1.  Clone the repository:
    ```bash
    git clone https://github.com/your-username/classified-frontend.git
    ```
2.  Navigate to the project directory:
    ```bash
    cd classified-frontend
    ```
3.  Install the dependencies:
    ```bash
    npm install
    ```

### Running the Development Server

To run the app in development mode, execute the following command:

```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) with your browser to see the result.

## Available Scripts

In the project directory, you can run the following scripts:

-   `npm run dev`: Runs the app in development mode.
-   `npm run build`: Builds the app for production.
-   `npm run start`: Starts the production server.
-   `npm run lint`: Lints the code using ESLint.

## Environment Variables

This project requires some environment variables to be set. Create a `.env.local` file in the root of the project and add the following:

```
NEXT_PUBLIC_IMG_URL=your_image_base_url
```

Replace `your_image_base_url` with the base URL of your image server.

## Deployment

The easiest way to deploy your Next.js app is to use the [Vercel Platform](https://vercel.com/new?utm_medium=default-template&filter=next.js&utm_source=create-next-app&utm_campaign=create-next-app-readme) from the creators of Next.js.

Check out the [Next.js deployment documentation](https://nextjs.org/docs/deployment) for more details.

## Contributing

Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.


## License
This project is licensed under the D-Bug Station Ltd .

