import { Link } from "next-view-transitions";

export default function NotFound() {
  return (
    <div className="flex flex-col items-center justify-center min-h-[50vh] text-center">
      <h1 className="text-4xl font-bold">404</h1>
      <h2 className="text-2xl font-semibold mt-4">Page Not Found</h2>
      <p className="text-gray-600 mt-2">The page you are looking for does not exist.</p>
      <Link href="/" style={{ '--hover-bg': `black`, '--hover-txt':"white" }} className="mt-6 px-4 py-2 btn-hover-effect bg-skyBlue  text-white rounded">
        Go back home
      </Link>
    </div>
  )
}
