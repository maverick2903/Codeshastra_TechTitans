"use client";
import { Divider, Link } from "@nextui-org/react";
import { button as buttonStyles } from "@nextui-org/theme";
import { motion } from "framer-motion";
import NextLink from "next/link";

import { subtitleVariants, titleVariants } from "@/Components/variants";
import { cn } from "@/utils/ui";

export default function HeroSection() {
  return (
    <>
      <div className="absolute -top-4 right-[11rem] -z-10 h-[20rem] w-[31.25rem] transform-gpu rounded-full bg-[#D3FD50]  blur-[10rem] dark:bg-[#d2fd505a] md:-top-0 md:h-[31.25rem] md:w-[30rem] md:blur-[20rem] lg:blur-[18rem] xl:w-[68.75rem]"></div>
      <Divider className="top-full hidden md:absolute md:block" />
      <div className="absolute inset-0 -z-10 w-full overflow-hidden bg-[linear-gradient(to_right,#80808012_1px,transparent_2px),linear-gradient(to_bottom,#80808012_1px,transparent_2px)] bg-[size:24px_24px]  md:h-[500px] lg:h-[743px] xl:h-screen"></div>
      <div className="z-30 flex flex-col items-center justify-center gap-4 py-8 md:py-10 ">
        <motion.div
          initial={{ opacity: 0, scale: 0 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{
            duration: 0.2,
          }}
          className="inline-block justify-center text-center md:max-w-3xl lg:max-w-6xl"
        >
          <h1
            className={cn(
              titleVariants(),
              "text-stone-500 dark:text-slate-300",
            )}
          >
            The Future of&nbsp;
          </h1>
          <br />
          <h1 className={cn(titleVariants({ color: "foreground" }), "")}>
            automation&nbsp;
          </h1>
          <h1 className={cn(titleVariants(), "")}>via&nbsp;</h1>
          <h1 className={cn(titleVariants({ color: "foreground" }), "")}>
            Voice Control&nbsp;
          </h1>
          <br />
          <h1
            className={cn(
              titleVariants({}),
              "block font-thin text-stone-500 dark:text-slate-300",
            )}
          >
            is Here&nbsp;
          </h1>
          {/* <h1
            className={cn(
              titleVariants(),
              "text-stone-500 dark:text-slate-300",
            )}
          >
            Game in Construction.
          </h1> */}
          <motion.h2
            initial={{ opacity: 0, scale: 0 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{
              duration: 0.2,
              delay: 0.5,
            }}
            className={cn(
              subtitleVariants({ class: "mt-4" }),
              "text-stone-800 dark:text-slate-500 ",
            )}
          >
            For the specially abled, or, simple the lazy.
          </motion.h2>
        </motion.div>
        <motion.div
          className="flex gap-3"
          initial={{ opacity: 0, scale: 0 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{
            type: "spring",
            stiffness: 100,
            delay: 0.7,
            duration: 0.7,
          }}
        >
          <Link
            as={NextLink}
            about="Find out why you should care about us"
            href={"/analytics"}
            className={buttonStyles({
              color: "success",
              radius: "full",
              variant: "shadow",
            })}
          >
            Get started
          </Link>
          <Link
            as={NextLink}
            className={buttonStyles({
              variant: "bordered",
              radius: "full",
              color: "primary",
            })}
            href="/about"
          >
            Learn More →
          </Link>
        </motion.div>
      </div>
    </>
  );
}