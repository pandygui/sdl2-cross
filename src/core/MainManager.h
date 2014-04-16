#ifndef CORE_MAINMANAGER_H
#define CORE_MAINMANAGER_H

#include <memory>

#include <util/Log.h>
#include <util/SDL.h>
#include <util/SDL_Event_fwd.h>


class Timer;
class GraphicsManager;

/**
 * MainManager class for managing application internals
 * Initializes all core systems.
 * Errors and failures are reported to logger.
 *
 * Singleton class, as only one should ever be created.
 *
 * @author SwarmingLogic (Roald Fernandez)
 */
class MainManager
{
public:
  static MainManager& instance();

  virtual ~MainManager();

  /**
   * Program main loop
   */
  void run();

  /**
   * Called prior to run()
   */
  void initialize();

  /**
   * Called after finalizing run() (exiting main loop)
   */
  void finalize();

  Uint32 getRuntimeTics() const;
  float getRuntimeSecs() const;
  float getCurrentTimeDelta() const;

private:
  MainManager();
  void handleEvent(const SDL_Event& event);

  void initSDL();
  void initSDLimg();
  void initSDLttf();
  void initSDLmixer();


  void logSDLVersion(const std::string& what,
                     const SDL_version& compiled,
                     const SDL_version& linked);

  void logSDLVersion(const std::string& what,
                     const SDL_version& compiled,
                     const SDL_version& linked,
                     std::string revision);


  // NonCopyable
  MainManager(const MainManager& c);
  MainManager& operator=(const MainManager& c);

  Log log_;
  std::unique_ptr<GraphicsManager> graphics_;
  std::unique_ptr<Timer> runtime_;
  float currentTimeDelta_;
  bool isRunning_;
};

#endif