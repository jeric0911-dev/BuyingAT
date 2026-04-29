"use client";

import { sentMessage } from "@/actions/others";
import { success } from "@/constants";
import Image from "next/image";
import { Link } from "next-view-transitions";
import Pusher from "pusher-js";
import { useEffect, useState } from "react";

const ChatBox = ({ user, conversation, config, id, messagesData }) => {
  const [inputFocused, setInputFocused] = useState(false);
  const [messages, setMessages] = useState(messagesData);
  const [text, setText] = useState("");

  useEffect(() => {
    if (config && id) {
      const pusher = new Pusher(config?.pusher_app_key, {
        cluster: config?.pusher_app_cluster,
      });
      const channel = pusher.subscribe(`conversation.${id}`);
      channel.bind("message.sent", (data) => {
        setMessages((prev) => [data.message, ...prev]);
      });

      return () => {
        pusher.unsubscribe(`conversation.${id}`);
      };
    }
  }, [id, config]);

  const handleMessage = async (e) => {
    e.preventDefault();
    const res = await sentMessage({
      conversation_id: id,
      message: text,
    });
    if (res.status === success) {
      setText("");
      // setMessages((p) => [res.data, ...p]);
    }
  };

  return (
    <div className="xl:border border-skyBlue/30 flex flex-col overflow-hidden rounded">
      <div className="xl:hidden">
        {!inputFocused && (
          <Link href={`/products/${conversation?.product?.id}`}>
            <div className="py-2 border-y border-dashed border-tGray">
              <div className="grid grid-cols-[66px_1fr] items-center gap-4">
                <div className="relative rounded-2xl overflow-hidden size-[66px]">
                  <Image
                    src={`${process.env.NEXT_PUBLIC_IMG_URL}/${conversation?.product?.get_gallery_images?.[0]?.img}`}
                    alt=""
                    fill
                    className="object-cover"
                  />
                </div>
                <div className="overflow-hidden space-y-1.5 *:leading-none">
                  <p className="text-lg text-tBlack font-semibold">
                    {conversation?.product?.product_title}
                  </p>
                  <p className="text-[#444444CC] font-bold truncate">
                    {conversation?.product?.get_product_user?.name}
                  </p>
                  <p className="text-skyBlue font-semibold">$ 5200</p>
                </div>
              </div>
            </div>
          </Link>
        )}
      </div>
      <div className="bg-skyBlue/10 px-5 py-3 hidden xl:flex items-center">
        <Image
          src={`${process.env.NEXT_PUBLIC_IMG_URL}/${conversation?.product?.get_product_user?.profile_img}`}
          alt=""
          width={48}
          height={48}
          className="rounded-full size-12 object-cover border-2 border-skyBlue"
        />
        <p className="text-lg text-tBlack font-semibold pl-3.5">
          {conversation?.product?.get_product_user?.name}
        </p>
      </div>
      <div
        className={`xl:px-5 py-3 ${
          inputFocused ? "max-h-[calc(100%-60px)]" : "max-h-[calc(100%-145px)]"
        } xl:max-h-[calc(100%-128px)] overflow-y-auto`}
      >
        <ul className="h-full flex flex-col-reverse xl:overflow-y-auto custom-scrollbar overflow-y-auto">
          {messages.map((item, i) => (
            <li
              key={i}
              className={`flex ${
                item?.user_id == user?.id ? "justify-end" : "justify-start"
              }`}
            >
              <div>
                {item?.message ? (
                  <p
                    className={`mt-[6px] max-w-lg px-3 py-2 text-sm rounded-3xl ${
                      item?.user_id == user?.id
                        ? "bg-skyBlue text-white"
                        : "bg-skyBlue/10 text-dark"
                    }`}
                  >
                    {item?.message}
                  </p>
                ) : item?.url ? (
                  <Image
                    src={`${process.env.NEXT_PUBLIC_IMG_URL}/${item?.url}`}
                    alt="#"
                    width={0}
                    height={0}
                    sizes="100vw"
                    className="h-36 w-auto mt-[6px]"
                  />
                ) : null}
              </div>
            </li>
          ))}
        </ul>
      </div>
      <form
        onSubmit={handleMessage}
        className="bg-skyBlue/10 xl:rounded-b h-14 -mx-4 xl:mx-0 px-5 flex items-center justify-between mt-auto"
      >
        <input
          type="text"
          placeholder="Write your message"
          className="bg-transparent h-full outline-none w-5/6"
          value={text}
          onChange={(e) => setText(e.target.value)}
          onFocus={() => setInputFocused(true)}
          onBlur={() => setInputFocused(false)}
        />
        <div className="flex items-center">
          {/* <label htmlFor="attach">
            <input
              onChange={(e) => setImage(e.target.files[0])}
              type="file"
              name="file"
              id="attach"
              className="hidden"
            />
            <Image src="/icon/attachment.svg" alt="" width={25} height={25} />
          </label> */}
          <button
            type="submit"
            disabled={!text}
            className="disabled:opacity-60 disabled:bg-transparent bg-transparent"
          >
            <Image
              src="/icon/send.svg"
              alt=""
              width={25}
              height={25}
              className="ml-2"
            />
          </button>
        </div>
      </form>
    </div>
  );
};

export default ChatBox;
