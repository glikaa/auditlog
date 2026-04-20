"""Startup script – patches asyncio.run for Python 3.6 compatibility."""
import sys
import asyncio

if sys.version_info < (3, 7):
    def _asyncio_run(coro):
        loop = asyncio.new_event_loop()
        try:
            asyncio.set_event_loop(loop)
            return loop.run_until_complete(coro)
        finally:
            loop.close()
    asyncio.run = _asyncio_run

import uvicorn

if __name__ == "__main__":
    uvicorn.run("main:app", host="127.0.0.1", port=8000)
