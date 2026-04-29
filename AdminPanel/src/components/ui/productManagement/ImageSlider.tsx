import { Box, IconButton, Stack } from "@mui/material";
import { type TouchEvent, type MouseEvent, useEffect, useState } from "react";

const ImageSlider = ({ slides }: any) => {
  const [currentSlide, setCurrentSlide] = useState(0);
  const [touchPosition, setTouchPosition] = useState<number | null>(null);
  const [mousePosition, setMousePosition] = useState<number | null>(null);
  const [isDragging, setIsDragging] = useState(false);
  
  useEffect(() => {
    const interval = setInterval(() => {
      nextSlide();
    }, 5000);
    return () => clearInterval(interval);
  }, [currentSlide]);

  const nextSlide = () => {
    setCurrentSlide((prev) => (prev + 1) % slides.length);
  };

  const goToSlide = (index: number) => {
    setCurrentSlide(index);
  };

  // Touch handlers
  const handleTouchStart = (e: TouchEvent) => {
    setTouchPosition(e.touches[0]?.clientX);
  };

  const handleTouchMove = (e: TouchEvent) => {
    if (touchPosition === null) return;

    const currentTouch = e.touches[0].clientX;
    const diff = touchPosition - currentTouch;

    if (diff < -5) {
      setCurrentSlide((prev) => (prev - 1 + slides.length) % slides.length);
    } else if (diff > 5) {
      nextSlide();
    }
    setTouchPosition(null);
  };

  // Mouse handlers for drag functionality
  const handleMouseDown = (e: MouseEvent) => {
    setMousePosition(e.clientX);
    setIsDragging(true);
    e.preventDefault(); // Prevent text selection
  };

  const handleMouseMove = (e: MouseEvent) => {
    if (!isDragging || mousePosition === null) return;

    const currentMouse = e.clientX;
    const diff = mousePosition - currentMouse;

    // Only trigger if dragged more than 50px to avoid accidental swipes
    if (diff > 50) {
      nextSlide();
      setIsDragging(false);
      setMousePosition(null);
    } else if (diff < -50) {
      setCurrentSlide((prev) => (prev - 1 + slides.length) % slides.length);
      setIsDragging(false);
      setMousePosition(null);
    }
  };

  const handleMouseUp = () => {
    setIsDragging(false);
    setMousePosition(null);
  };

  const handleMouseLeave = () => {
    setIsDragging(false);
    setMousePosition(null);
  };

  return (
    <Box position="relative">
      <Box
        onTouchStart={handleTouchStart}
        onTouchMove={handleTouchMove}
        onMouseDown={handleMouseDown}
        onMouseMove={handleMouseMove}
        onMouseUp={handleMouseUp}
        onMouseLeave={handleMouseLeave}
        sx={{
          overflow: "hidden",
          borderRadius: 1,
          cursor: isDragging ? 'grabbing' : 'grab',
          userSelect: 'none', // Prevent text selection during drag
        }}
      >
        <Box
          sx={{
            display: "flex",
            transition: isDragging ? 'none' : "transform 1s ease-in-out",
            transform: `translateX(-${currentSlide * 100}%)`,
          }}
        >
          {slides?.map((item: any, index: any) => (
            <Box
              key={index}
              sx={{
                position: "relative",
                width: "100%",
                height: 250,
                flexShrink: 0,
                borderRadius: 1,
              }}
            >
              <img
                src={`${import.meta.env.VITE_IMG_URL}/${item?.img}`}
                alt="img"
                style={{
                  width: "100%",
                  height: "100%",
                  objectFit: "cover",
                  borderRadius: "8px",
                  pointerEvents: "none", // Prevent image drag
                }}
                draggable={false} // Prevent native image drag
              />
            </Box>
          ))}
        </Box>
      </Box>

      <Stack
        direction="row"
        spacing={1}
        position="absolute"
        bottom={16}
        left="50%"
        sx={{ transform: "translateX(-50%)" }}
      >
        {slides.map((_: any, index: any) => (
          <IconButton
            key={index}
            onClick={() => goToSlide(index)}
            aria-label={`Go to slide ${index + 1}`}
            sx={{
              width: 10,
              height: 10,
              borderRadius: "50%",
              backgroundColor:
                currentSlide === index ? "primary.main" : "#ADB7BC",
              transition: "all 0.3s",
              padding: 0,
            }}
          />
        ))}
      </Stack>
    </Box>
  );
};

export default ImageSlider;