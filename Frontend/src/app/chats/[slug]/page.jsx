import ChattingList from "@/components/chats/ChattingList";
import Container from "@/components/shared/Container";
import relativeTime from "dayjs/plugin/relativeTime";
import dayjs from "dayjs";
import Image from "next/image";
import {
  getAllConversation,
  getMessagesById,
  getPusherConfig,
} from "@/actions/others";
import { getUser } from "@/actions/auth";
import ChatBox from "@/components/chats/ChatBox";
import { Link } from "next-view-transitions";
dayjs.extend(relativeTime);

export const metadata = {
  title: "Chats",
  robots: { index: false },
};

const ChatDetailsPage = async ({ params: { slug } }) => {
  const { data } = await getAllConversation();
  const { data: user } = await getUser();
  const { data: messages } = await getMessagesById(slug);
  const { data: config } = await getPusherConfig();
  const conversation = data?.find((item) => item.id == slug);

  return (
    <Container>
      <div className="xl:border border-border rounded xl:p-7 lg:mt-6 h-[calc(100vh-90px)] lg:h-[calc(100vh-250px)] xl:h-[calc(100vh-250px)] overflow-hidden">
        <div className="grid grid-cols-1 xl:grid-cols-[362px_1fr_288px] gap-5 size-full">
          <div className="space-y-3 overflow-y-auto no-scrollbar hidden xl:block">
            {data?.map((item) => (
              <ChattingList key={item.id} data={item} id={slug} />
            ))}
          </div>
          <ChatBox
            user={user}
            conversation={conversation}
            config={config}
            id={slug}
            messagesData={messages}
          />
          <div className="xl:flex flex-col justify-between hidden">
            <div className="space-y-4">
              <Image
                src={`${process.env.NEXT_PUBLIC_IMG_URL}/${conversation?.product?.get_gallery_images?.[0]?.img}`}
                alt=""
                width={0}
                height={0}
                sizes="100vw"
                className="h-48 w-full rounded"
              />
              <div className="flex justify-between items-center">
                <p className="flex items-center gap-2">
                  <Image
                    src="/icon/time-circle.svg"
                    alt="clock icon"
                    width={13}
                    height={13}
                  />
                  <span className="text-sm text-tBlack">
                    {dayjs(conversation?.product?.updated_at).fromNow()}
                  </span>
                </p>
                {/* <button className="flex justify-center items-center gap-2 bg-orange rounded text-white text-xs font-medium">
                  <Image
                    src="/icon/boost.svg"
                    alt="boost icon"
                    width={8}
                    height={11}
                  />
                  BOOST
                </button> */}
              </div>
              <p className="text-lg text-tBlack font-semibold">
                {conversation?.product?.product_title}
              </p>
              <p className="text-lg text-skyBlue font-extrabold">
                $ {conversation?.product?.discounted_price}
              </p>
              {/* <p className="flex items-center gap-1.5">
                <Image
                  src="/icon/location.svg"
                  alt="location"
                  width={11}
                  height={16}
                />
                <span className="text-tBlack">Dhaka bangladesh</span>
              </p> */}
            </div>
            <Link
              href={`/products/${conversation?.product?.id}`}
              className="border border-skyBlue bg-skyBlue/10 text-skyBlue font-bold h-10 rounded flex items-center justify-center"
            >
              View Product
            </Link>
          </div>
        </div>
      </div>
    </Container>
  );
};

export default ChatDetailsPage;
