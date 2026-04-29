"use client";

import { useTransitionRouter } from "next-view-transitions";
import Image from "next/image";
import { useState } from "react";

const Search = () => {
  const [text, setText] = useState("");
  const router = useTransitionRouter()

  const handleSearch = (e) => {
    e.preventDefault();
    if (text !== "") {
      setText("");
      router.push(`/blogs?search=${text}`);
    } else {
      router.push("/blogs");
    }
  };

  return (
    <div className="border border-border p-6 rounded-md">
      <p className="font-medium">SEARCH</p>
      <form onSubmit={handleSearch} className="relative w-full h-11 mt-6">
        <input
          type="text"
          onChange={(e) => setText(e.target.value)}
          value={text}
          className="form-input focus:ring-0 focus:border-skyBlue h-full w-full border border-border rounded-sm text-sm px-4"
          placeholder="Search for anything..."
        />
        <button type="submit" aria-label="Search button">
          <Image
            src="/icon/search.svg"
            alt="#"
            width={20}
            height={20}
            className="absolute right-0 top-0 my-3 mr-4"
          />
        </button>
      </form>
    </div>
  );
};

export default Search;
